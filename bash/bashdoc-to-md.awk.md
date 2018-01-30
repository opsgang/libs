# simple bash docs - bashdoc-to-md.awk

TL;DR? [Skip to the example](#example)

* [Get The Gist](#get-the-gist)

* [Format Rules](#format-rules)

    * [@section](#section-annotation)

    * [function docco: @desc](#function-annotation-desc)

    * [function docco: @example](#function-annotation-example)

    * [global vars](#global-vars)

* [Example](#example)

    * [annotated script](#annotated-script)

    * [rendered output](#rendered-output)

    * [raw outpu](#raw-output)

 EXAMPLE ANNOTATED SCRIPT
   

## Get The Gist

H1 header automatically taken from file name.

TOC automatically generated from @section and @desc annotations.

To document a function put a @desc annotation and optional @example
annotations directly above the relevant function.

Functions that are not preceded by an @desc annotation are
considered undocumented.

Global vars are documented automatically.

Now see [the example](#example).

---

## Format Rules

### section annotation

Must be a single line.

Valid _section_ annotation: line that starts exactly `# @section`
followed by the _section_ name.

bashdoc-to-md.awk will create a section heading in the TOC
and in the body of the output.

It will then add all following _annotated_ function names under that section
heading in the TOC as links to the function descriptions in the document body.

A section is considered finished at the next _section_ annotation or EOF.

### function annotation: @desc

Can be multiline.

Valid _desc_ annotation: line that starts exactly `# @desc`.

It can be multiline. Each line of the function description should start
with a leading `#` char.

The description is considered complete at the next @example annotation
or actual function declaration.

You don't need to put the name of the function in the `desc` as
it is automatically taken from the real function declaration in your
script.

### function annotation: @example

Can be multiline.

Any _example_ annotation with out a _desc_ annotation above it
is ignored.

The example must directly precede the relevant function.

Valid _example_ annotation: line that is exactly `# @example`.

Anything else on that line is ignored.

All lines of the example must start exactly `#` followed by *3* spaces.

### global vars

Documentation for these is generated automatically from
any assignment that starts at the beginning of a line.

i.e. there must be no leading whitespace, and the line
must contain an `=` sign.

In this case, the name of the var is assumed to be the
LHS of the assignment.

Anything on the RHS is documented as the value.

If the RHS (quoted or unquoted) consists of `${some_var}`
this is documented as a var set in the current script env.

If the RHS (quoted or unquoted) is `${some_var:-some default}`
then the default is also documented.


## EXAMPLE

Click [here](#rendered-output) to view rendered.

Click [here](#raw-output) to view raw markdown.

### ANNOTATED SCRIPT

```bash
# EXAMPLE: awk -f bashdoc-to-md my_funcs.sh
#<-- this hash is the 1st char column of file

# ...global vars - this line is irrelevant for doc

# ... path to foo binary
FOO=${FOO:-echo}

BAR="some string"

_IGNORED="this global is ignored as it starts with underscore"

# @section String Functions

# @desc Prints _foo:_ plus user passed strs.
#
# Return *1* on err. I can use **markdown** here.
#
# @example
#   foo "hi!" # foo says hi!
#
foo() {
    [[ -z "$1" ]] && return 1
    $FOO "foo says $*"
}

ignored() {
    # bashdoc-to-md ignores this function because
    # there is no preceding @desc annotation.
}

# @section Useless Functions

# @desc Spurious lesser func when you consider
# the glory of [foo()](#foo) <-- see this inline link.
#
function bar() {
    return 0
}
```

### RENDERED-OUTPUT

# my\_funcs.sh
---
# GLOBALS

* `$FOO`: _... path to foo binary_
    * reads env var `$FOO`
    * or default val: `echo`

* `$BAR`
    * value: `"some string"`


# FUNCTIONS

## String Functions
---
* [foo()](#foo)
## Useless Functions
---
* [bar()](#bar)

---

## String Functions
---
### foo()

Prints _foo:_ plus user passed strs.

Return *1* on err. I can use **markdown** here.

#### Example

```bash
foo "hi!" # foo says hi!

```

## Useless Functions
---
### bar()

Spurious lesser func when you consider
the glory of [foo()](#foo) <-- see this inline link.

---

**End of RENDERED-OUTPUT**


### RAW-OUTPUT
```
# my\_funcs.sh
---
# GLOBALS

* `$FOO`: _... path to foo binary_
    * reads env var `$FOO`
    * or default val: `echo`

* `$BAR`
    * value: `"some string"`


# FUNCTIONS

## String Functions
---
* [foo()](#foo)
## Useless Functions
---
* [bar()](#bar)

---

## String Functions
---
### foo()

Prints _foo:_ plus user passed strs.

Return *1* on err. I can use **markdown** here.

#### Example

```bash
foo "hi!" # foo says hi!

```

## Useless Functions
---
### bar()

Spurious lesser func when you consider
the glory of [foo()](#foo) <-- see this inline link.

```

**End of RAW-OUTPUT**