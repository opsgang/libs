# ./std/functions.git
---
## GLOBALS

* `$GIT`
    * reads env var `$GIT`
    * or default val: `git --no-pager`

* `$GIT_SHA_LEN`
    * reads env var `$GIT_SHA_LEN`
    * or default val: `8`


## Functions

* [check\_for\_changes()](#check_for_changes)
* [sha\_in\_origin()](#sha_in_origin)

---

## check\_for\_changes()

checks a dir (defaults to current dir) for git changes.
Returns 1 if there are uncommitted git changes.

### Example

```bash
check_for_changes "/in/my/cloned/dir" || exit 1
```

## sha\_in\_origin()

makes sure a git commit exists in the remote origin.
Returns 1 if commit does not exist.

Defaults to using the value of $GIT_SHA, or else the 
current dir's HEAD sha1.

### Example

```bash
# ... current dir's HEAD git sha1 exists in origin?
unset GIT_SHA; sha_in_origin || exit 1

# sha1 438704b exists in origin?
sha_in_origin 438704b || exit 1
```

