#!/usr/bin/env bats
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#
print_on_err() {
    echo "START OUTPUT--|$output|--END OUTPUT"
    echo "status: $status"
}

setup() {
    . habitual/std.functions || return 1
}

@test "run_if_exists run func with no args" {
    local foo=""
    # ... setup
    foo() { echo "foo bar $@"; }

    # ... run
    run std::run_if_exists "foo"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    echo $output | grep -q '^foo bar *$'
}

@test "run_if_exists run func with args" {
    local foo=""
    # ... setup
    foo() { echo "foo bar $@"; }

    # ... run
    run std::run_if_exists "foo" "arg1" "arg2"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    echo $output | grep -q '^foo bar arg1 arg2 *$'
}

@test "run_if_exists fails if func name not passed" {
    run std::run_if_exists
    [[ $status -ne 0 ]]
    echo "$output" | grep -q 'expects function name as 1st arg'
}

@test "run_if_exists success but runs nothing if func does not exist" {
    # ... setup
    DEBUG=true

    # ... run
    run std::run_if_exists "foo"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    echo "$output" | grep -q "function 'foo()' not found"
}

@test "run_if_exists success but runs nothing if invalid function name" {
    # ... setup
    DEBUG=true

    # ... run
    run std::run_if_exists "; foo"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    echo "$output" | grep -q "function '; foo()' not found"
}

@test "run_if_exists returns the exit code of the function" {
    local foo=""
    # ... setup
    foo() { echo "foo bar $@"; return 212; }

    # ... run
    run std::run_if_exists "foo" "arg1" "arg2"
    print_on_err

    # ... verify
    [[ $status -eq 212 ]]
    echo $output | grep -q '^foo bar arg1 arg2 *$'
}

