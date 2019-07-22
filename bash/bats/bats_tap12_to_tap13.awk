#!/usr/bin/awk -f
#
# usage: awk -f bats_tap12_to_tap13.awk /path/to/bash/script > output.tap13
#

# BEGIN used for top level declarations for vars that need a reset per top-level match.
BEGIN {
    tap13 = ""
    sys_out = ""
    cmd_output = ""
}

function append_sysout(sys_out, cmd_output) {
    if (sys_out) {
        if (cmd_output) {
            sys_out = sys_out "  output: |\n" cmd_output
        }
        sys_out = "  ---\n" sys_out "  ...\n"
        tap13 = tap13 sys_out
    }
    return tap13
}

! /^#/ {
    tap13 = append_sysout(sys_out, cmd_output)
    sys_out = ""
    cmd_output = ""
    tap13 = tap13 $0 "\n"
}

/^#/ {
    in_sys_out = 1
}

in_sys_out {
    if (! /^#/) {
        in_cmd_out = 0
        in_sys_out = 0
    }
    else {
        file_name = ""
        line_no = ""
        status = ""
        line = ""
        failed_assertion = ""
        if (/.*in test file/) {
            file_name = $0
            sub(/^.*in test file */, "", file_name)
            sub(/,.*$/, "", file_name)

            line_no = $0
            sub(/^.*line */, "", line_no)
            sub(/[^0-9]+$/, "", line_no)
            sys_out = sys_out "  file: " file_name "\n"
            sys_out = sys_out "  line: " line_no "\n"
        }
        else if (/^# *status: [0-9]+/) {
            status = $0
            gsub(/[^0-9]/, "", status)
            sys_out = sys_out "  status: " status "\n"

        }
        else {
            line = $0
            sub(/^# */, "    ", line)
            cmd_output = cmd_output line "\n"
        }
    }
}

END {
    tap13 = append_sysout(sys_out, cmd_output)
    sys_out = ""
    cmd_output = ""
    print tap13
}
