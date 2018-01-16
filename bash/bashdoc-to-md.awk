#!/usr/bin/awk -f
#
# usage: awk -f bashdoc-to-md.awk /path/to/bash/script > /path/to/README.md
#
# Based heavily on https://github.com/reconquest/shdoc/blob/master/shdoc
# by Stanislav Seletskiy
#
# Modified from that to
#
# - simplified to only handle @description and @example annotations.
# - document global vars
#
BEGIN {
    if (! style) {
        style = "github"
    }

    styles["h1", "from"]   = ".*"
    styles["h1", "to"]     = "## &"

    styles["h2", "from"]   = ".*"
    styles["h2", "to"]     = "### &"

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

/^([A-Za-z][^=[:blank:]]*)=/ {
    ln=$0
    varname = $1
    val = $0
    sub(/=.*/, "", varname)
    sub(/[^=]+=/, "", val)

    if (match(val, /\$\{.+}/)) {
        sub(/^["'\$\{]+/, "", val)
        sub(/["'\}]+$/, "", val)

        invar = "" def = ""
        if (match(val, /:-/)) {
            invar = val
            def = val
            sub(/:-.*/, "", invar)
            sub(/^[^:]+:-/, "", def)
        }
    }

    if (invar) {
        defaults = "    * reads env var `$" invar "`\n"
        if (def) {
            defaults = defaults "    * or default val: `" def "`\n"
        }
    }
    else if (val) {
        defaults = ": value: `" val "`\n"
    }
    else {
        defaults = ":_no value_\n"
    }

    vardoc = vardoc "\n* _\$" varname "_\n" defaults

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

in_example {
    if (! /^#[ ]{3}/) {
        in_example = 0

        docblock = docblock "\n" render("/code") "\n"
    } else {
        sub(/^#[ ]{3}/, "")

        docblock = docblock "\n" $0
    }
}

/^# @example/ {
    in_example = 1

    docblock = docblock "\n" strip_md(render("h2", "Example"))
    docblock = docblock "\n\n" strip_md(render("code", "bash"))
}

/^(function )?([a-zA-Z0-9_:-]+)(\(\))? \{/ && docblock != "" {
    sub(/^function /, "")

    doc = doc "\n" strip_md(render("h1", $1)) "\n" docblock

    url = $1
    gsub(/\W/, "", url)

    toc = toc "\n" "* [" $1 "](#" url ")"

    docblock = ""
}

END {
    if (vardoc) {
        vardoc = "## GLOBALS\n" vardoc "\n"
    }
    print "# " FILENAME "\n" "---"
    print vardoc
    print "## Functions"
    print toc
    print "\n---"
    print doc
}
