# std/functions
---

# Functions

## MISC. FUNCTIONS
---
* [source\_files()](#source_files)
* [required\_vars()](#required_vars)
* [envsubst\_tokens\_list()](#envsubst_tokens_list)
* [random\_str()](#random_str)
* [semver\_a\_ge\_b()](#semver_a_ge_b)
## LOG MESSAGE FUNCTIONS
---
* [e()](#e)
* [i()](#i)
* [d()](#d)
* [red\_e()](#red_e)
* [bold\_i()](#bold_i)
* [yellow\_i()](#yellow_i)
* [green\_i()](#green_i)
* [blue\_i()](#blue_i)

---

## MISC. FUNCTIONS
---
### source\_files()

sources a list of files in to current env.

If you have whitespace in your file names, that's your
own fault.

#### Example

```bash
source_files "./foo /bar/foo ../foo"
# or ...
source_files "./foo" "/bar/spaces\ in-name"

```

### required\_vars()

Checks a list of vars for undefined
or empty vals. 

**Whitespace and _0_ are considered values.**

Returns 1 if any are undefined or empty.

#### Example

```bash
# ... test to see $FOO and $BAR are non-empty.
required_vars "FOO BAR" || exit 1

```

### envsubst\_tokens\_list()

produces the SHELL-FORMAT arg suitable for
the `envsubst` cmd, from a list of var names.

This is useful to tell envsubst not to replace shell vars
in a template str or file unless they are listed in the
SHELL-FORMAT.

`man envsubst` for more info (part of _GNU gettext_ utils)

#### Example

```bash
# ... produces "${FOO} ${BAR}"
str=envsubst_tokens_list "FOO BAR"

```

### random\_str()

creates random str of format <datetime>-<integer>-<integer>
Useful for docker container names (or suffixes) to "guarantee" uniqueness.

### semver\_a\_ge\_b()

compares 2 semver strs and returns success if arg1 is >= arg2.
  Any leading 'v' is stripped before comparison.

#### Example

```bash
semver_a_ge_b 0.100.10 0.10.10 # true (as v 0.100 is greater than v0.10)

semver_a_ge_b 0.99.0 0.99.0    # true (as args are the same)

semver_a_ge_b v0.99.0 0.99.0   # true (as args are the same, ignoring the leading v)
```

## LOG MESSAGE FUNCTIONS
---
### e()

prints ERROR to STDERR, with context prefix and
stacktrace.

Caller can pass multiple quoted strings as each line
of the error msg.
_\n_ within a str is also treated as newline.

#### Example

```bash
 # script.sh
 some_func { e "... went wrong!\nBadly" "Really Badly." }
 some_func

# ... would print something like:
# ERROR script.sh:some_func(): ... went wrong!
# ERROR script.sh:some_func(): ... Badly
# ERROR script.sh:some_func(): ... Really Badly.
# ERROR script.sh:some_func(): TRACE:
# ERROR script.sh:some_func(): some_func() (line 2)
# ERROR script.sh:some_func():       main() (line 3)

```

### i()

prints INFO msg (STDOUT) with context prefix
Caller can pass multiple quoted strings as each line
of the msg.
_\n_ within a str is also treated as newline.

#### Example

```bash
i "msg line 1" "line 2\nline3"

# ... would print something like:
# INFO script.sh:main(): ... msg line 1
# INFO script.sh:main(): ... line 2
# INFO script.sh:main(): ... line 3

```

### d()

prints DEBUG msg (STDOUT) with context prefix
Caller can pass multiple quoted strings as each line
of the msg.
_\n_ within a str is also treated as newline.

#### Example

```bash
d "msg line 1" "line 2\nline3"
```

### red\_e()

as with e(), but msg text is coloured
### bold\_i()

as with i(), but msg text is highlighted
### yellow\_i()

as with i(), but msg text is coloured.
### green\_i()

as with i(), but msg text is coloured.
### blue\_i()

as with i(), but msg text is coloured.
