# terraform/functions.terraform
---
# GLOBALS

* `$TERRAFORM`: _... path to terraform binary - set this in env or make sure it is in your PATH_
    * reads env var `$TERRAFORM`
    * or default val: `empty string`

* `$TERRAFORM_INIT_OPTS`: _... any opts to pass `init` (or `remote config` if tf <=v0.8.8 ) on [terraform\_init](#terraform\_init)_
    * reads env var `$TERRAFORM_INIT_OPTS`
    * or default val: `empty string`

* `$TERRAFORM_APPLY_OPTS`: _... any opts to pass `apply` on [terraform\_apply](#terraform\_apply)_
    * reads env var `$TERRAFORM_APPLY_OPTS`
    * or default val: `empty string`

* `$TERRAFORM_GET_OPTS`: _... with old tf (<=v0.8.8) any opts to pass `terraform get` on [terraform\_init](#terraform\_init)_
    * reads env var `$TERRAFORM_GET_OPTS`
    * or default val: `empty string`

* `$KEEP_PLUGINS`: _... set to non-empty to keep downloaded terraform modules._
    * reads env var `$KEEP_PLUGINS`
    * or default val: `empty string`

* `$DEVMODE`: _... set to non-empty value to skip git checks and `terraform apply`_
    * reads env var `$DEVMODE`
    * or default val: `empty string`


# FUNCTIONS

* [tf()](#tf)
* [terraform\_version()](#terraform_version)
* [terraform\_cleanup()](#terraform_cleanup)
* [terraform\_init()](#terraform_init)
* [terraform\_apply()](#terraform_apply)
* [terraform\_run()](#terraform_run)

---

### tf()

Returns the path to the terraform binary.

Optionally, user can set $TERRAFORM in env, to force the use of a particular binary.

### terraform\_version()

Runs terraform --version.

Used internally to pick which terraform subcommands to run.

Affected by global [$TERRAFORM](#globals).

### terraform\_cleanup()

Deletes any terraform cache or downloaded state files from the local workspace.

**Do not use this if you are not using a remote state backend.**

Used to ensure a clean terraform run.

If you are using terraform 0.10.0+, you can set $KEEP_PLUGINS to non-empty
and any downloaded plugins will not be deleted (to save some run time).

### terraform\_init()

Will run terraform subcommands to initialise / fetch remote state, any modules and plugins.

Some [globals](#globals) - $TERRAFORM, $TERRAFORM_INIT_OPTS, TERRAFORM_GET_OPTS - affect behaviour.

### terraform\_apply()

Runs `terraform apply` - for v0.11.0+, will add the -auto-approve to run it non-interactively.

Some [globals](#globals) - $TERRAFORM, $TERRAFORM_APPLY_OPTS, $DEVMODE - affect behaviour.

Set $TERRAFORM_APPLY_OPTS to pass `apply` any other options.

When $DEVMODE is set, `apply` is not actually run.

### terraform\_run()

Wrapper cmd to perform terraform subcommands for `init` (or `remote cfg`/`get`), `plan`, `apply`.

Will use `remote cfg` and `get` instead of `init` for older terraform versions.

Will run `apply -auto-approve` for newer versions of terraform.

See [terraform_init](#terraform_init) and [terraform_apply](#terraform_apply).

User can define own functions that will run before and after `init`
and before and after `apply`. (See [lifecycle hooks](#lifecycle-hooks))

#### DEVMODE

_Used to test your terraform **with out modifying any real infrastructure**_.

See the caveat when you are writing your own lifecycle hooks.

`terraform apply` will not run if $DEVMODE is set in env.

Additionally, unless DEVMODE is set in env, `apply` will only run if
the git commit being run exists in the **origin** repo.

This is to prevent users changing infrastructure but not pushing their
changes, and also to ensure that the git audit info is accurate.

#### lifecycle_* hooks

**CAVEAT** - if you are using any hooks to modify your actual infrastructure, make sure to
make them no-op if $DEVMODE is set in the env.

* `terraform_preinit`:
   after [terraform\_cleanup](#terraform_cleanup) but before [terraform\_init](#terraform_init).

   Use this to set any TF_VAR_ variables in your env, or preprocess files.

* `terraform_postinit`:
   after [terraform\_init](#terraform_init) but before `terraform plan`.

   Use this to post-process any fetched modules or sanity check your env.

* `terraform_preapply`
   after checking the git commit exists in the origin, but before [terraform\_apply](#terraform_apply).

* `terraform_postapply`
   after [terraform\_apply](#terraform_apply).

   Use this to perform any other non-terraform-related operations to complete your provisioning.

#### Example

```bash

    # example: preinit func used to get and set all terraform vars
    terraform_preinit() {
        export TF_VAR_host_size="humungous"
        export TF_VAR_secret="$(get_secret)"
    
        required_vars "TF_VAR_host_size TF_VAR_secret" || return 1
    }
    
    terraform_run "/my/tf/dir" || exit 1 # will use $TF_VAR* on `plan` and `apply`


    # example: postapply func used to switch dns to route traffic from 'blue' to 'green' stack
    terraform_postapply() {
        [[ -n "$DEVMODE" ]] && i "DEVMODE, so no-op." && return 0
        stack=$(which_stack_is_not_live)
        set_dns "live-$stack.example.com" || return 1
    }

    terraform_run "/my/tf/dir" || exit 1 # unless DEVMODE, will apply terraform and switch dns.
    
```

