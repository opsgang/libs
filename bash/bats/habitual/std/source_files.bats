#!/usr/bin/env bats
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#
print_on_err() {
    echo "START OUTPUT--|$output|--END OUTPUT"
    echo "status: $status"
}

setup() {
    . habitual/std.functions || return 1
    export TMPDIR=$BATS_TMPDIR/$BATS_TEST_NAME
    mkdir -p $TMPDIR || true
}

teardown() {
    rm -rf $BATS_TMPDIR/$BATS_TEST_NAME || true
}

@test "source_files can source multiple files" {
    local f1="" f2="" # temp files to source

    # ... setup
    f1=$(mktemp) ; f2=$(mktemp) 
    echo "echo 'foo'" > $f1
    echo "echo 'bar'" > $f2

    # ... run
    run source_files $f1 $f2
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    echo $output | grep -q '^foo bar$'
}

@test "source_files can handle spaces in filenames" {
    local f1="" f2="" # temp files to source

    # ... setup
    TMPDIR="$TMPDIR/space in name"
    mkdir -p "$TMPDIR" ; f1="$(mktemp)" ; f2="$(mktemp)"

    echo "echo 'foo'">"$f1" ; echo "echo 'bar'">"$f2"

    # ... run
    run source_files "$f1" "$f2"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    echo $output | grep -q '^foo bar$'
}

@test "source_files fail if file with bad syntax" {
    local f1="" f2="" f3="" # temp files to source

    # ... setup
    f1="$(mktemp)" ; f2="$(mktemp)" ; f3="$(mktemp)"
    echo "echo 'foo'">$f1
    echo 'flumpty'>$f2 # flumpty is a bad command. Trust me.
    echo "echo 'bar'">$f3

    # ... run
    run source_files $f1 $f2 $f3
    print_on_err

    # ... verify
    [[ $status -ne 0 ]]

    echo "$output" | grep -qP "flumpty: command not found"
    echo "$output" | grep -qP "can not source $f2"

}

@test "source_files fail if file does not exist" {
    local f1="" f2="" f3="" # temp files to source

    # ... setup
    f1="$(mktemp)" ; f2="$(mktemp)" ; f3="$(mktemp)"
    echo "echo 'foo'">$f1
    echo 'flumpty'>$f2 # flumpty is a bad command. Trust me.
    rm $f3

    # ... run
    run source_files $f1 $f2 $f3
    print_on_err

    # ... verify
    [[ $status -ne 0 ]]

    echo "$output" | grep -qP " $f3 does not exist"
}

@test "source_files IGNORE_MISSING will skip missing files" {
    local f1="" f2="" f3="" # temp files to source
    
    # ... setup
    f1="$(mktemp)" ; f2="$(mktemp)" ; f3="$(mktemp)"
    rm $f2
    echo "echo 'foo'">$f1
    echo "echo 'bar'">$f3

    # ... run
    local IGNORE_MISSING=true
    run source_files $f1 $f2 $f3
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    echo $output | grep -q '^foo bar$'
}

@test "source_files IGNORE_MISSING still fail on bad syntax in source" {
    local f1="" f2="" f3="" # temp files to source

    # ... setup
    f1="$(mktemp)" ; f2="$(mktemp)" ; f3="$(mktemp)"
    echo "echo 'foo'">$f1
    rm $f2
    echo 'flumpty'>$f3 # flumpty is a bad command. Trust me.

    # ... run
    local IGNORE_MISSING=true
    run source_files $f1 $f2 $f3
    print_on_err

    # ... verify
    [[ $status -ne 0 ]]

    echo "$output" | grep -qP "flumpty: command not found"
    echo "$output" | grep -qP "can not source $f3"
}

