# std/functions.log\_msgs
---

## Functions

* [e()](#e)
* [i()](#i)
* [d()](#d)
* [red\_e()](#red_e)
* [bold\_i()](#bold_i)
* [yellow\_i()](#yellow_i)
* [green\_i()](#green_i)
* [blue\_i()](#blue_i)

---

## e()

prints ERROR to STDERR, with context prefix and
stacktrace.

Caller can pass multiple quoted strings as each line
of the error msg.
_\n_ within a str is also treated as newline.

### Example

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

## i()

prints INFO msg (STDOUT) with context prefix
Caller can pass multiple quoted strings as each line
of the msg.
_\n_ within a str is also treated as newline.

### Example

```bash
i "msg line 1" "line 2\nline3"

# ... would print something like:
# INFO script.sh:main(): ... msg line 1
# INFO script.sh:main(): ... line 2
# INFO script.sh:main(): ... line 3

```

## d()

prints DEBUG msg (STDOUT) with context prefix
Caller can pass multiple quoted strings as each line
of the msg.
_\n_ within a str is also treated as newline.

### Example

```bash
d "msg line 1" "line 2\nline3"
```

## red\_e()

as with e(), but msg text is coloured
## bold\_i()

as with i(), but msg text is highlighted
## yellow\_i()

as with i(), but msg text is coloured.
## green\_i()

as with i(), but msg text is coloured.
## blue\_i()

as with i(), but msg text is coloured.
