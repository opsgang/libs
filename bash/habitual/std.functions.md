# habitual/std.functions

>
> Functions used frequently, including stdout/stderr log msgs
>

* [GLOBALS](#globals)

* [FUNCTIONS](#functions)
    * [MISC. FUNCTIONS](#misc-functions)
    * [LOG MESSAGE FUNCTIONS](#log-message-functions)

---

# GLOBALS

* `$DEBUG`: _... set in env to non-empty value to print debug messages to STDERR (See [d()](#d))_
    * reads env var `$DEBUG`
    * or default val: `empty string`

* `$QUIET`: _... set in env to non-empty value to silence all messages apart from errors_
    * reads env var `$QUIET`
    * or default val: `empty string`



# FUNCTIONS

## MISC. FUNCTIONS
---
* [source\_files()](#source_files)
* [required\_vars()](#required_vars)
* [str\_to\_safe\_chars()](#str_to_safe_chars)
* [safe\_chars\_def\_list()](#safe_chars_def_list)
* [envsubst\_tokens\_list()](#envsubst_tokens_list)
* [random\_str()](#random_str)
* [semver\_a\_ge\_b()](#semver_a_ge_b)
* [multiline\_to\_single()](#multiline_to_single)
* [single\_to\_multiline()](#single_to_multiline)
* [base64\_encode()](#base64_encode)
* [base64\_decode()](#base64_decode)
* [export\_build\_url()](#export_build_url)
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

Sources a list of files in to your current bash env.

> User can set `$IGNORE_MISSING` to skip files that do not exist.
>
> However an existing file that is unreadable (due to file perms)
> or contains bad syntax will still raise an error.

#### Example

```bash
source_files "./foo /bar/foo ../foo"
# or ...
source_files "./foo" "/bar/spaces\ in-name"

# ... ignore files that don't exist
IGNORE_MISSING=true source_files "default.cfg env.cfg project.cfg"

```


---

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


---

### str\_to\_safe\_chars()

Prints a user-passed *single-line* str with all instances of certain chars
replaced by a safe character.

*See examples  if you are working with UTF-8 wide-byte chars*

Useful for creating vals that can be consumed by systemd environment AND sourced by a shell script
both of which treat quotes, whitespace and `$` signs differently.

Or to create valid AWS tag values (there is a limited set of valid chars)

* Arg 1: *single-line* str to transform

* Arg 2: Optional: the replacement char, defaults to `_`

> To use `]` and/or `[` in Arg 2, they must appear at start of pattern in that order
> (after any leading `!` if you want to specify a disallowed list)
> 
> To use `-` in Arg2, it MUST appear as the last char.
> You can use named POSIX character classes e.g. [:blank:] or [:alnum:].

* Arg 3: Optional: the list of chars to keep (*or replace if prefixed with* `!`)

> To include a literal `!` in a list to replace, add another exclamation mark.
> 
> The default is strict, replacing all but alphanumerics and these chars:`_.:/=+-@`

Call [safe_chars_def_list](#safe_chars_def_list) to get the default char list.

#### Example

```bash
# ... default
#
str_to_safe_chars 'from_repo:"git@github.com/me/foo"'
    # output: from_repo:_git@github.com/me/foo_

# ... handling UTF-8 (e.g using copyright char as replacement)
# Ensure your shell's locale is set up for utf8 first ... e.g.
loc=en_US.UTF-8 ; export LC_ALL="$loc" LC_CTYPE="$loc" LANG="$loc" LANGUAGE="$loc"
str_to_safe_chars "-C-" "$(printf '\xC2\xA9')" '!C' # replace C with copyright symbol

# ... for safe AWS tag (transform same chars as default, but whitespace is fine)
#
str_to_safe_chars "from repo: <git@github.com/me/foo>" '_' "$(safe_chars_def_list)[:blank:]"
    # output: from repo:_git@github.com/me/foo_

# ... for val in systemd env file that can also be sourced by shell script
#
# so no backslash, `$`, backtick, whitespace,`"`, or `'`.
#
bad_chars='!\$`[:blank:]"'"'" # Note leading ! indicates list is of chars to replace
str_to_safe_chars 'price (in $USD):"5.00"' '-' "$bad_chars"
    # output: price-(in--USD):-5.00-

# ... strip all non-alphanumerics except hyphens and underscores
#
str_to_safe_chars "from repo: <git@github.com/me/foo>" '_' '[:alnum:]_-'
    # output: from_repo__git_github_com_me_foo_


```


---

### safe\_chars\_def\_list()

Prints default list of allowed chars for
[str_to_safe_chars()](#str_to_safe_chars)

---

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


---

### random\_str()

creates random str of format <datetime>-<integer>-<integer>
Useful for docker container names (or suffixes) to "guarantee" uniqueness.


---

### semver\_a\_ge\_b()

compares 2 semver strs and returns success if arg1 is >= arg2.

Any leading 'v' is stripped before comparison.
Works with prerelease and metadata info.

_Returns 2 on arg err_

#### Example

```bash
semver_a_ge_b 0.100.10 0.10.10 # true (as v 0.100 is greater than v0.10)

semver_a_ge_b 0.99.0 0.99.0    # true (as args are the same)

semver_a_ge_b v0.99.0 0.99.0   # true (as args are the same, ignoring the leading v)

semver_a_ge_b 0.99.0-beta V0.99.0-alpha # true (as beta beats alpha)

```


---

### multiline\_to\_single()

Concatenates a multiline string, converting newlines to \n

STDOUT: concatenated line
*NOTE: the argument is double quoted if a variable, to preserve real newlines.*

#### Example

```bash
my_str="This is
a multiline string"
multiline_to_single "$my_str"

# ... would print something like:
# This is\na multiline string

```


---

### single\_to\_multiline()

Splits a string on '\n' to multiple lines with real newlines.

STDOUT: Multiple lines

These are an alternative to the `base64_encode` and
`base64_decode` functions, for example, when base64 produces
too long a string. Try storing an ssh key in AWS parameter store
and see what I mean ...

#### Example

```bash
my_str="This will be\na multiline string"
single_to_multiline "$my_str"

# ... would print something like:
# This will be
# a multiline string

```


---

### base64\_encode()

Encodes a string (or mulitline string) as Base64

You can use this and `base64_decode` when you need to pass
or store multiline strings as a single line.

These are an alternative to the `single_to_multiline` and
`multiline_to_single` functions when you wish to preserve existing
'\n' instances in your strings, and not convert them to newlines
or vice-versa.


---

### base64\_decode()

Decodes a base64 string

You can use this and `base64_decode` when you need to pass
or store multiline strings as a single line.


---

### export\_build\_url()

Exports $BUILD_URL if available from a number of possible sources.

$BUILD_URL is a link to a CI/CD job's run.

Returns 1 if BUILD_URL can not be determined. 

Use this to annotate your builds and deployments with governance metadata. e.g. the job run
should show you who built what when.

[shippable](https://shippable.com), [circleci](https://circleci.com) and [jenkins](https://jenkins.io)
provide an equivalent var. This func just exports it with a standard name.

TravisCI [does not](https://github.com/travis-ci/travis-ci/issues/8935), but it is
possible to construct it.


---

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


---

### i()

prints INFO msg (STDOUT) with context prefix.

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


---

### d()

prints DEBUG msg (STDERR) with context prefix.

Caller can pass multiple quoted strings as each line
of the msg.
_\n_ within a str is also treated as newline.

#### Example

```bash
d "msg line 1" "line 2\nline3"
```


---

### red\_e()

as with e(), but msg text is coloured

---

### bold\_i()

as with i(), but msg text is highlighted

---

### yellow\_i()

as with i(), but msg text is coloured.

---

### green\_i()

as with i(), but msg text is coloured.

---

### blue\_i()

as with i(), but msg text is coloured.

---

