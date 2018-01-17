# std/functions.git
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
* [is\_git\_clone()](#is_git_clone)
* [git\_branch()](#git_branch)
* [git\_repo()](#git_repo)
* [git\_sha()](#git_sha)
* [git\_tag()](#git_tag)
* [git\_user()](#git_user)
* [git\_email()](#git_email)
* [git\_id()](#git_id)
* [git\_info\_vars()](#git_info_vars)

---

## check\_for\_changes()

checks a dir (defaults to current dir) for git changes.
Returns 1 if there are uncommitted git changes.
User can pass the dir path as an arg. If not, ./ is checked.

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
```

## is\_git\_clone()

Tests whether a path is inside a git-cloned dir
Returns 1 if not.

User can pass path to test as arg. Defaults to current dir.

### Example

```bash
```

## git\_branch()

Prints branch name unless you've checked out a tag (prints from-a-tag).
Returns 1 if current working dir is not in a git repo.
## git\_repo()

Prints remote.origin.url from current dir's git config.
## git\_sha()

Prints sha of current commit - up to `$GIT_SHA_LEN` chars.
## git\_tag()

Prints out the git-tag on the current commit (exact match only)
## git\_user()

Prints user.name (from git config)
## git\_email()

Prints user.email (from git config)
## git\_id()

Prints user.name user.email (from git config)
## git\_info\_vars()

`export` of `$GIT_INFO` - _sanitised_ str formed of repo, sha1, tag, branch info
with special chars replaced with underscores.

`$GIT_INFO` is suitable to use as an AWS tag value, or to consume in a shell script.
Also exported is `$RAW_GIT_INFO` - the unsanitized version of the str.

### Example

```bash
GIT_REPO
```

