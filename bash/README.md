[1]: https://github.com/opsgang/fetch#tag-constraint-expressions \"OG fetch tag constraints\"
[2]: https://github.com/opsgang/fetch/releases \"OG fetch releases\"
[3]: bash/bashdoc-to-md.awk.md
# libs/bash

_Make your life easier and consistent when scripting automation, by sourcing these libs._

Tested bundles are available on the [releases page](https://github.com/opsgang/libs/releases).

> **You need to have GNU coreutils, and realpath installed for these scripts to work.**
>
> They also rely on GNU versions of `grep`, `sed`, `awk`, `sort` and `find`.
>
> BSD flavours will not work, so Mac users should `homebrew` some GNU-ey goodness
> before using these scripts locally.

* [BUNDLES](#bundles)
    * [HOWTO: USE ONE](#use-one)
    * [HOWTO: GET ONE](#get-one)

* [TESTS](#tests)

* [DOCS - bashdoc](#docs)

---

---

## BUNDLES

On a release, we create attached bundles (_read_ .tgz) that contains all libs required to perform
a specific automation goal. e.g to run [terraform](https://terraform.io) in a consistent and
non-interactive way.

The bundles all contain an entrypoint script that does all of the sourcing of the
other libs for you.

### HOWTO: USE ONE

Just source the entrypoint script which is always called `opsgang.sourcelibs`.

e.g. If you've installed the bundle under /my/dir ...

```bash
# In my calling script, use the opsgang libs:
. /my/dir/opsgang.sourcelibs || exit 1
```

### HOWTO: GET ONE

#### ... I want an exact version or the latest

```bash
# ... download and untgz latest terraform_run in /my/dir
mkdir -p /my/dir
curl   -L -H 'Accept: application/octet-stream' \
    https://github.com/opsgang/libs/releases/download/latest/terraform_run.tgz \
    | tar -xvz -C /my/dir

# ... or replace /latest in url with desired tag e.g. /0.0.1
```

#### ... I want to specify a version constraint like '~1.0'

```bash
curl --retry 3 -L \
    https://raw.githubusercontent.com/opsgang/libs/master/bash/bundles/dl_release.sh \
| GITHUB_OAUTH_TOKEN=<github access token> bash -s -- <bundle> <ver constraint> <dl dir>

# e.g to download and untgz terraform_run.gz, the latest 1.x version to /my/dir/:
curl --retry 3 -L \
    https://raw.githubusercontent.com/opsgang/libs/master/bash/bundles/dl_release.sh \
| GITHUB_OAUTH_TOKEN=$token bash -s -- terraform_run.gz '~1.0' /my/dir
```

> GITHUB\_OAUTH\_TOKEN can be omitted, but your downloads will be rate-limited.
>
> The local download dir will be created if needed.
>
> See the [opsgang/fetch README][1] for a description of version constraints.
>
> If you already have [opsgang/fetch][2] in your \$PATH, dl\_release.sh will be quicker.

## TESTS

Each lib file has a corresponding test script that is run as part of CI.

Specific Tests in a test script can be run (or all by default).

A convenience function is in the example below, if you want to run all available test scripts.

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

## DOCS

> Each lib file has its own .md documentation that sits alongside it in this repo.

The markdown is generated from a simple inline markup ([see here for more info][3]).

To generate it yourself for all lib files.

```bash
cd bash
libs=$(find ./ -path './t' -prune -o -name '*.functions' -print)
for lib in $libs; do awk -f bashdoc-to-md.awk $lib > $lib.md ; done
```

