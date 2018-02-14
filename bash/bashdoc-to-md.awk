#!/usr/bin/awk -f
#
# usage: awk -f bashdoc-to-md.awk /path/to/bash/script > /path/to/README.md
#
# Based heavily on https://github.com/reconquest/shdoc/blob/master/shdoc
# by Stanislav Seletskiy
#
# - simplified to only handle @description and @example annotations.
# - allows grouping of functions using @section delimiter.
# - document global vars
#   - comment on line directly above var is assumed to be optional var desc.
#   - str or default values taken from any assignment to var
#     only accounts for:
#       var="some str"    # val is 'some str'. Quotes are ignored. 
#       var="${FOO}"      # val is ${FOO} from env
#       var="${FOO:-bar}" # val is either ${FOO} or default 'bar'
BEGIN {
    if (! style) {
        style = "github"
    }

    styles["h2", "from"]   = ".*"
    styles["h2", "to"]     = "## &"

    styles["h3", "from"]   = ".*"
    styles["h3", "to"]     = "### &"

    styles["h4", "from"]   = ".*"
    styles["h4", "to"]     = "#### &"

    styles["code", "from"] = ".*"
    styles["code", "to"]   = "```&"

    styles["/code", "to"]  = "```"

}

function render(type, text) {
    return gensub( \
        styles[type, "from"],
        styles[type, "to"],
        "g",
        text \
    )
}

function strip_md(text) {
    sub(/[ #`]+$/, "", text)
    return text
}

# global vars
/^([A-Za-z][^=[:blank:]]*)=/ {
    ln = $0
    val = $0
    varname = $1
    var_comment = ""
    invar = ""
    def = ""
    defaults = ""

    sub(/=.*/, "", varname)
    sub(/[^=]+=/, "", val)

    # ... get any default values for global var
    if (match(val, /\$\{.+}/)) {
        sub(/^["'\$\{]+/, "", val)
        sub(/["'\}]+$/, "", val)

        # ... if ${VAR:-default} style
        if (match(val, /:-/)) {
            invar = val
            def = val
            sub(/:-.*/, "", invar)
            sub(/^[^:]+:-/, "", def)
            if (!def) {
                def = "empty string"
            }
        }
        else { # ... if ${VAR}
            invar = val
        }
    }

    # ... assume comment on previous line is var description
    if (match(prev, /^# /)) {
        sub(/^# /, "", prev)
        gsub(/_/, "\\_", prev)
        var_comment = prev
    }

    if (invar) {
        defaults = "    * reads env var `$" invar "`\n"
        if (def) {
            defaults = defaults "    * or default val: `" def "`\n"
        }
    }
    else if (val) {
        defaults = "    * value: `" val "`\n"
    }
    else {
        defaults = "    * _no value_\n"
    }

    if (var_comment) {
        vardoc = vardoc "\n* `\$" varname "`: _" var_comment "_\n" defaults
    }
    else {
        vardoc = vardoc "\n* `\$" varname "`\n" defaults
    }


} { 
    prev=$0
    def = ""
    defaults = ""
    invar = ""
    ln = ""
    val = ""
    varname = ""
    var_comment = ""
}

/^# @overview/ {
    in_overview = 1
    overviewdoc = ""
}

in_overview {
    if (/^[^#]|^ *$/) {
        in_overview = 0
    } else {
        sub(/^# @overview/, "")
        sub(/^# /, "")
        sub(/^# *$/, "")
        if (match($0, /^.+$/)) { # ignore empty lines
            overviewdoc = overviewdoc "\n" $0
        }
    }
}

/^# @desc/ {
    in_desc = 1
    in_example = 0

    docblock = ""
}

in_desc {
    if (/^[^#]|^# @[^d]/) {
        in_desc = 0
    } else {
        sub(/^# @desc /, "")
        sub(/^# /, "")
        sub(/^#$/, "")

        docblock = docblock "\n" $0
    }
}

/^# @section/ {

        sub(/^# @section /, "")

        ftoc = ftoc "\n## " $0 "\n---"

        doc = doc "\n## " $0 "\n---" 
}

in_example {
    if (! /^#/) {
        in_example = 0

        docblock = docblock "\n" render("/code") "\n"
    } else {
        sub(/^#([ ]{3})?/, "")

        docblock = docblock "\n" $0
    }
}

/^# @example/ {
    in_example = 1

    docblock = docblock "\n" strip_md(render("h4", "Example"))
    docblock = docblock "\n\n" strip_md(render("code", "bash"))
}

/^(function )?([a-zA-Z0-9_:-]+)(\(\))? \{/ && docblock != "" {
    sub(/^function /, "")
    name = $1
    gsub(/_/, "\\_", name)

    doc = doc "\n" strip_md(render("h3", name)) "\n" docblock "\n\n" "---\n"

    url = name
    gsub(/\W/, "", url)

    ftoc = ftoc "\n" "* [" name "](#" url ")"

    docblock = ""
}

END {
    if (overviewdoc) {
        overviewdoc = "\n" overviewdoc "\n"
    }
    if (vardoc) {
        vardoc = "\n# GLOBALS\n" vardoc "\n"
        if (ftoc) {
            toptoc = "\n* [GLOBALS](#globals)\n\n* [FUNCTIONS](#functions)\n"
        }
    }
    fn = FILENAME
    sub(/^\.\//, "", fn)
    gsub(/_/, "\\_", fn)
    print "# " fn overviewdoc toptoc "\n---"
    print vardoc
    print "\n# FUNCTIONS"
    print ftoc
    print "\n---"
    print doc
}
