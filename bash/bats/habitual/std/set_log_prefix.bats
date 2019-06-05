#!/usr/bin/env bats
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#
print_on_err() {
    echo "START OUTPUT--|$output|--END OUTPUT"
    echo "status: $status"
}

setup() {
    export LIB=habitual/std.functions
    export TMPDIR=$BATS_TMPDIR/$BATS_TEST_NAME
    export FROM_STACKFRAME=0

    mkdir -p $TMPDIR || true

    . $LIB || return 1
}

teardown() {
    rm -rf $TMPDIR || true
}

mkscript() {
    local script="$1"
    local f=""
    f=$(mktemp)
    cat <<EOF > $f
#!/bin/bash -e
$script
EOF

    chmod a+x $f
    echo "$f"
}

@test "set_log_prefix run from script - global" {
    local f="" ; f=$(mkscript ". $LIB ; set_log_prefix")
    run $f
    print_on_err

    [[ "$output" == "$(basename $f):main()" ]]
}

@test "set_log_prefix run from script - function" {
    local f="" ; f=$(mkscript ". $LIB ; foo() { set_log_prefix ; } ; foo")
    run $f
    print_on_err

    [[ "$output" == "$(basename $f):foo()" ]]
}

@test "set_log_prefix run from shell" {
    run bash -c ". $LIB && set_log_prefix"
    print_on_err

    [[ "$output" == "bash" ]]
}

@test "set_log_prefix subshells ignored for caller stack" {
    # nested subshells and command expansion example
    # - we still expect the log prefix to indicate foo() and not the subshell
    script='. $LIB ; foo() { ( ( o=$(set_log_prefix) ; echo "$o") ) ; } ; foo'
    local f=""; f=$(mkscript "$script")
    run $f
    print_on_err

    [[ "$output" == "$(basename $f):foo()" ]]
}

@test "set_log_prefix run in sourced file" {
    # ... should yield $f2:source() - source is a special bash call stack id
    local f2=""; f2=$(mkscript "set_log_prefix")
    local f1=""; f1=$(mkscript ". $LIB ; main() { . $f2 ; } ;  main")
    run $f1
    print_on_err

    [[ "$output" == "$(basename $f2):source()" ]]
}

@test "set_log_prefix DEBUG_ABS_PATHS set" {
    local f="" ; f=$(mkscript ". $LIB ; DEBUG_ABS_PATHS=true set_log_prefix")
    run $f
    print_on_err

    [[ "$output" == "$(realpath -- ${f}):main()" ]]
}

@test "set_log_prefix FROM_STACKFRAME of func declaring set_log_prefix" {
    # ... setup
    FROM_STACKFRAME=0
    local f3=""; f3=$(mkscript "f3_main() { set_log_prefix ; } ;")
    local f2=""; f2=$(mkscript "f2_main() { . $f3 ; f3_main ; } ; ")
    local f1=""; f1=$(mkscript ". $LIB ; f1_main() { . $f2 ;  f2_main ; } ;  f1_main")

    # ... run
    run $f1
    print_on_err

    # ... verify
    [[ "$output" == "$(basename $f3):f3_main()" ]]
}

@test "set_log_prefix FROM_STACKFRAME for parent of func declaring set_log_prefix" {
    # ... setup
    FROM_STACKFRAME=1
    local f3=""; f3=$(mkscript "f3_main() { set_log_prefix ; } ;")
    local f2=""; f2=$(mkscript "f2_main() { . $f3 ; f3_main ; } ; ")
    local f1=""; f1=$(mkscript ". $LIB ; f1_main() { . $f2 ;  f2_main ; } ;  f1_main")

    # ... run
    run $f1
    print_on_err

    # ... verify
    [[ "$output" == "$(basename $f2):f2_main()" ]]
}

@test "set_log_prefix FROM_STACKFRAME for grandparent of func declaring set_log_prefix" {
    # ... setup
    FROM_STACKFRAME=2
    local f3=""; f3=$(mkscript "f3_main() { set_log_prefix ; } ;")
    local f2=""; f2=$(mkscript "f2_main() { . $f3 ; f3_main ; } ; ")
    local f1=""; f1=$(mkscript ". $LIB ; f1_main() { . $f2 ;  f2_main ; } ;  f1_main")

    # ... run
    run $f1
    print_on_err

    # ... verify
    [[ "$output" == "$(basename $f1):f1_main()" ]]
}

