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

    vardoc = vardoc "\n* `\$" varname "`\n" defaults

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

        toc = toc "\n## " $0 "\n---"

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

    doc = doc "\n" strip_md(render("h3", name)) "\n" docblock

    url = name
    gsub(/\W/, "", url)

    toc = toc "\n" "* [" name "](#" url ")"

    docblock = ""
}

END {
    if (vardoc) {
        vardoc = "# GLOBALS\n" vardoc "\n"
    }
    fn = FILENAME
    sub(/^\.\//, "", fn)
    gsub(/_/, "\\_", fn)
    print "# " fn "\n" "---"
    print vardoc
    print "# Functions"
    print toc
    print "\n---"
    print doc
}
