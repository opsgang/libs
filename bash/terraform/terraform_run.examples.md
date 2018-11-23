# terraform\_run functions cookbook

## USE THE RELEASE BUNDLE

```bash
# ... fetch and unpack release bundle
wget https://github.com/opsgang/libs/releases/download/0.0.8/terraform_run.tgz
mkdir -p /custom/libs ; tar xzvf terraform_run.tgz -C /custom/libs

# ... source libs
. /custom/libs/opsgang.sourcelibs

# ... run some terraform in a git repo
terraform_run /my/terraform/project
```

## OVERRIDE GOVERNANCE AND COMMIT / ORIGIN CHECKS

```bash
tf_export_governance_vars() { :; } # don't generate gov vars from git info
no_unpushed_changes() { :; } # don't verify project repo commits all pushed to origin
terraform_run /my/terraform/project
```

## RUN BUT DON'T APPLY TERRAFORM
```bash
# DEVMODE=true (also disables checking git commits / origin up-to-date)
DEVMODE=true terraform_run /my/terraform/project
```

## FULL AUTO: NO INPUT, NO APPROVAL
```bash
# ... auto-approve true by default, just input to disallow
TERRAFORM_APPLY_OPTS="-input=false" terraform_run /my/terraform/project
```
