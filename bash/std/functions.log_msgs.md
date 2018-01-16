# ./std/functions.log_msgs
---

## Functions

* [some\_func](#some_func)
* [e()](#e)
* [i()](#i)
* [d()](#d)
* [red\_e()](#red_e)
* [bold\_i()](#bold_i)
* [yellow\_i()](#yellow_i)
* [green\_i()](#green_i)
* [blue\_i()](#blue_i)

---

## some\_func

prints ERROR to STDERR, with context prefix and
stacktrace.

Caller can pass multiple quoted strings as each line
of the error msg.
_\n_ within a str is also treated as newline.

### Example

```bash
# script.sh
some_func { e "... went wrong!\nBadly" "Really Badly." }
## e()

some_func
```

## i()

prints INFO msg (STDOUT) with context prefix
Caller can pass multiple quoted strings as each line
of the msg.
_\n_ within a str is also treated as newline.

### Example

```bash
i "msg line 1" "line 2\nline3"
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
