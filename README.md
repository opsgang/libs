[1]: https://github.com/opsgang/fetch
# libs

... reusable scripts - retrieve specific versions with [opsgang/fetch][1] :)


## Running tests

```bash

cd bash

t() {
    local suite="$1" rc=0
    [[ "$(basename $(realpath -- .))" != "bash" ]] && echo 'ERROR: run from ./bash dir' && return 1
    [[ -z "$suite" ]] && echo 'ERROR: pass suite name' >&2 && return 1

    libs=$(find $suite -type f | grep -v 'README' | grep -vP '\.(md|markdown|txt)$')
    for lib in $libs; do
        rc=0
        [[ ! -x "t/$lib" ]] && echo "no tests for $lib" && continue
        t/$lib || rc=1
    done

    return $rc
}

# run tests for functions under ./std
t ./std

```

## USAGE

Typically we source all files (not READMEs, though!) under bash/std/ in our scripts

To grab these to a local dir e.g. ./lib, you can use fetch:

```bash

# retrieve latest v 1.x (but < 2.x) of files under bash/std
fetch --repo="https://github.com/opsgang/libs" --tag="~> 1.0" --source-path=/bash/std ./lib/std

# Now source all std libs in your scripts with something like:
for lib in $(find ./std -type f | grep -v 'README' | grep -vP '\.(md|markdown|txt)$'); do
    ! . $lib && echo "ERROR $0: ... could not source $lib" && return 1
done

```
