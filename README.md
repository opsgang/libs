[1]: https://github.com/opsgang/fetch
# libs

... reusable scripts - retrieve specific versions with [opsgang/fetch][1] :)

[![Run Status](https://api.shippable.com/projects/5a588d01e0a7bb07007efbd7/badge?branch=master)](https://app.shippable.com/github/opsgang/libs)

**You need to have GNU coreutils installed for these scripts to work.**

Mac users: We use `realpath`, and GNU versions of `sed`, `awk`, `sort`.

BSD flavours will not work, so `homebrew` some GNU-ey goodness if you plan to use these scripts locally.

## USAGE

Typically we source all scripts under bash/habitual/ in our scripts

To grab these to a local dir e.g. ./lib, you can use fetch:

```bash

# retrieve latest v 1.x (but < 2.x) of files under bash/habitual
fetch --repo="https://github.com/opsgang/libs" --tag="~> 1.0" --source-path=/bash/habitual ./lib/habitual

# Now source all habitual libs in your scripts with something like:
for lib in $(find ./habitual -type f | grep -v 'README' | grep -vP '\.(awk|md|markdown|txt)$'); do
    ! . $lib && echo "ERROR $0: ... could not source $lib" && return 1
done

```

## DOCUMENTATION

Generated from simple inline markup.

To generate it yourself:

```bash
cd bash
libs=$(find ./ -path './t' -prune -o -name '*.functions' -print)
for lib in $libs; do awk -f bashdoc-to-md.awk $lib > $lib.md ; done
```

## BUILDS / PKGS

Currently these run tests against the bash functions.

TODO:

On a git tag push event, create bundles of related scripts and upload
as binary assets to a github release. e.g. all utility scripts for running terraform,
or building an AMI _opsgang_ style.

These could then be retrieved with [opsgang/fetch][1].

## TESTS

```bash

cd ./bash # all tests must be run from this dir.

# to run all tests for a particular script e.g. habitual/std.functions:
t/habitual/std.functions

# to run individual tests for a script e.g. for habitual/functions
t/habitual/std.functions t_can_source_multiple_files t_check_var_defined

# to run all tests for all scripts under ./habitual
t() {
    local suite="$1" rc=0
    [[ "$(basename $(realpath .))" != "bash" ]] && echo 'ERROR: run from ./bash dir' && return 1
    [[ -z "$suite" ]] && echo 'ERROR: pass suite name' >&2 && return 1

    libs=$(find $suite -path './t' -prune -o -name '*.functions' -print)
    for lib in $libs; do
        rc=0
        f="t/${lib#./}"
        [[ ! -x "$f" ]] && echo "no tests for $lib" && continue
        $f || rc=1
    done

    return $rc
}

# ... then you can run things like ...
t ./ || echo "FAILURES"       # run tests for all functions.
t habitual || echo "FAILURES" # run tests for all functions under habitual

```

