#!/usr/bin/env bats
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#
print_on_err() {
    echo "START OUTPUT--|$output|--END OUTPUT"
    if [[ ! -z "$exp_output" ]]; then
        echo "  EXP OUTPUT--|$exp_output|--EXP OUTPUT"
    fi
    echo "status: $status"
}

setup() {
    export LIB=$(realpath habitual/std.functions)
    export TMPDIR=$BATS_TMPDIR/$BATS_TEST_NAME

    mkdir -p $TMPDIR || true

    . $LIB || return 1
}

teardown() {
    rm -rf $TMPDIR || true
}

mkscript() {
    local script="$1"
    local f=$(mktemp)
    cat <<EOF > $f
#!/bin/bash -e
$script
EOF

    chmod a+x $f
    echo "$f"
}

@test "__stacktrace output meets expected format" {
    # ... setup
    f3=$(mkscript "f3_main() { . $LIB ; FROM_STACKFRAME=0 ; __stacktrace && true ; } ;")
    f2=$(mkscript "f2_main() { . $f3 ; f3_main ; } ; ")
    f1=$(mkscript "f1_main() { . $f2 ;  f2_main ; } ;  f1_main")

    # exp_output will also contain the main() from the temp bats script
    # but this is enough to verify the format we expect
    exp_output="f3_main() (file: $f3, line: 2)\\n"
    exp_output="$exp_output  f2_main() (file: $f2, line: 2)\\n"
    exp_output="$exp_output    f1_main() (file: $f1, line: 2)\\n"

    # ... run
    run $f1
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "$exp_output"* ]]
}

