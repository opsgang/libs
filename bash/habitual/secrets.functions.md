# habitual/secrets.functions

>
> agnostic public interface for pluggable secrets management functions.
>

* [GLOBALS](#globals)

* [FUNCTIONS](#functions)

---

# GLOBALS

* `$SECRETS_PROVIDER`: _... defines user-defined provider e.g. ssm - see [known\_providers()](#known\_providers)_
    * reads env var `$SECRETS_PROVIDER,,`



# FUNCTIONS

* [set\_secrets\_provider()](#set_secrets_provider)
* [known\_providers()](#known_providers)
* [required\_funcs()](#required_funcs)

---

### set\_secrets\_provider()

Configures secrets management functions to use the expected provider.

Pass a valid secrets provider. See [known_providers()](#known_providers) for getting the list.
Sets `$SECRETS_PROVIDER` for the user.

---

### known\_providers()

Prints supported secrets providers to STDOUT.

We expect a file named after this provider that contains [required functions](#required_funcs).

This is verified when [set_secrets_provider()](#set_secrets_provider) is run.


---

### required\_funcs()

Prints names of functions that must be defined.
We expect them to be defined in the provider's handler file -
the file that [set_secrets_provider()](#set_secrets_provider) sources.


---

