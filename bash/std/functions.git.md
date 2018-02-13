# std/functions.git
---
# GLOBALS

* `$GIT`: _path to git binary_
    * reads env var `$GIT`
    * or default val: `git --no-pager`

* `$GIT_SHA_LEN`: _git sha1s will be truncated to this length_
    * reads env var `$GIT_SHA_LEN`
    * or default val: `8`


# FUNCTIONS

## GIT INFO FUNCTIONS
---
* [git\_branch()](#git_branch)
* [git\_repo()](#git_repo)
* [git\_sha()](#git_sha)
* [git\_tag()](#git_tag)
* [git\_user()](#git_user)
* [git\_email()](#git_email)
* [git\_id()](#git_id)
* [git\_info\_str()](#git_info_str)
* [git\_vars()](#git_vars)
## VALIDATION FUNCTIONS
---
* [no\_unpushed\_changes()](#no_unpushed_changes)
* [check\_for\_changes()](#check_for_changes)
* [sha\_in\_origin()](#sha_in_origin)
* [is\_git\_clone()](#is_git_clone)

---

## GIT INFO FUNCTIONS
---
### git\_branch()

Prints branch name (or nothing if you've checked out a tag).
Returns 1 if current working dir is not in a git repo.
---
### git\_repo()

Prints remote.origin.url from current dir's git config.
Empty str if not set.
---
### git\_sha()

Prints sha of current commit - up to $GIT\_SHA\_LEN chars.
---
### git\_tag()

Prints out the git-tag on the current commit (exact match only)
Prints empty str if there is none.
---
### git\_user()

Prints user.name (from git config)
Returns 1 if not set.
---
### git\_email()

Prints user.email (from git config)
Returns 1 if not set.
---
### git\_id()

Prints user.name user.email (from git config)
Returns 1 if user.name not set.
---
### git\_info\_str()

Outputs a str formed of repo, sha1, tag and branch info.
User can pass a path to use for getting the git info

#### Example

```bash
# ... produce info str for current dir
out=$(git_info_str)

# ... produce info str for /my/project/repo
out=$(git_info_str /my/project/repo)

# example $out
# repo:git@github.com:opsgang/blah sha1:bc342d35 tag:-no tag- branch:master

```

---
### git\_vars()

Convenience function. Gets git info for current dir
Exports vars you can use for governance info.

EXPORTED VARS:

 $GIT\_REPO, $GIT\_BRANCH, $GIT\_TAG, $GIT\_SHA,

 $GIT\_USER, $GIT\_EMAIL, $GIT\_ID.

 Also $GIT\_INFO - [see git\_info\_str()](#git_info_str) for example value.

Each var has a corresponding function with the same name lowercased. See each
one's doc to understand its output.

**CAVEAT**: if you run this in a sub-shell e.g. $( git\_vars ) or ( git\_vars )
the values will not be available outside of the sub-shell.

#### Example

```bash
git_vars || exit 1
echo "I am in a local clone of $GIT_REPO on branch $GIT_BRANCH"

```

---
## VALIDATION FUNCTIONS
---
### no\_unpushed\_changes()

runs [check\_for\_changes](#check_for_changes) and 
[sha_in_origin](#sha_in_origin) for **current dir**.

If $DEVMODE is set, the checks will be skipped.

#### Example

```bash
# ... check whether what I'm deploying is reproducible
no_unpushed_changes || exit 1

# ... skip checks for now, I'm engineering ...
DEVMODE=true no_unpushed_changes || exit 1

```

---
### check\_for\_changes()

checks a dir (defaults to current dir) for git changes.

Returns 1 if there are uncommitted git changes.

User can pass the dir path as an arg.
If not the current dir is checked.

#### Example

```bash
check_for_changes "/in/my/cloned/dir" || exit 1

```

---
### sha\_in\_origin()

makes sure a git commit exists in the remote origin.
Returns 1 if commit does not exist.

Defaults to using the value of $GIT_SHA, or else the
current dir's HEAD sha1.

#### Example

```bash
# sha1 438704b exists in origin?
sha_in_origin 438704b || exit 1

# val of $GIT_SHA is in origin?
GIT_SHA=438704b sha_in_origin || exit 1

# ... current dir's HEAD sha1 exists in origin?
sha_in_origin || exit 1

```

---
### is\_git\_clone()

Tests whether a path is inside a git-cloned dir
Returns 1 if not.

User can pass path to test as arg. Defaults to current dir.

#### Example

```bash

is_git_clone || exit 1 # current dir is in a git clone?

is_git_clone /my/project/file || exit 1 # is file inside a git clone?

```

---
