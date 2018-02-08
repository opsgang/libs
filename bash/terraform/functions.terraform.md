# terraform/functions.terraform
---
# GLOBALS

* `$TERRAFORM`: _... path to terraform binary - set this in env or make sure it is in your PATH_
    * reads env var `$TERRAFORM`
    * or default val: `empty string`

* `$KEEP_PLUGINS`: _... set to non-empty to keep downloaded terraform modules._
    * reads env var `$KEEP_PLUGINS`
    * or default val: `empty string`

* `$DEVMODE`: _... set to non-empty value to skip git checks and `terraform apply`_
    * reads env var `$DEVMODE`
    * or default val: `empty string`

* `$TERRAFORM_INIT_OPTS`: _... any opts to pass `init` (or `remote config`) on calling [terraform\_init](#terraform\_init)_
    * reads env var `$TERRAFORM_INIT_OPTS`
    * or default val: `empty string`

* `$TERRAFORM_APPLY_OPTS`: _... any opts to pass `apply` on calling [terraform\_apply](#terraform\_apply)_
    * reads env var `$TERRAFORM_APPLY_OPTS`
    * or default val: `empty string`

* `$TERRAFORM_GET_OPTS`: _... with older tf versions set this and [terraform\_init](#terraform\_init) will pass `get` these opts._
    * reads env var `$TERRAFORM_GET_OPTS`
    * or default val: `empty string`


# FUNCTIONS


---

