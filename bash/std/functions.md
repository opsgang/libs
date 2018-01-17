# std/functions
---

## Functions

* [source\_files()](#source_files)
* [required\_vars()](#required_vars)
* [envsubst\_tokens\_list()](#envsubst_tokens_list)
* [random\_str()](#random_str)

---

## source\_files()

sources a list of files in to current env.

If you have whitespace in your file names, that's your
own fault.

### Example

```bash
source_files "./foo /bar/foo ../foo"
# or ...
source_files "./foo" "/bar/spaces\ in-name"

```

## required\_vars()

Checks a list of vars for undefined
or empty vals. 

**Whitespace and _0_ are considered values.**

Returns 1 if any are undefined or non-empty.

### Example

```bash
# ... test to see $FOO and $BAR are non-empty.
required_vars "FOO BAR" || exit 1

```

## envsubst\_tokens\_list()

produces the SHELL-FORMAT arg suitable for
the `envsubst` cmd, from a list of var names.

This is useful to tell envsubst not to replace shell vars
in a template str or file unless they are listed in the
SHELL-FORMAT.

`man envsubst` for more info (part of _GNU gettext_ utils)

### Example

```bash
# ... produces "${FOO} ${BAR}"
str=envsubst_tokens_list "FOO BAR"

```

## random\_str()

creates random str of format <datetime>-<integer>-<integer>
Useful for docker container names (or suffixes) to "guarantee" uniqueness.

