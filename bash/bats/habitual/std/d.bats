#!/usr/bin/env bats
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#
print_on_err() {
    echo "START OUTPUT--|$output|--END OUTPUT"
    echo "status: $status"
}

setup() {
    . habitual/std.functions || return 1
    unset DEBUG
    unset QUIET
}

@test "d has no output if DEBUG undefined" {
    # ... setup
    unset DEBUG

    # ... run
    run d "this str should not be in output"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ "$output" == "" ]]
}

@test "d has no output if DEBUG empty str" {
    # ... setup
    export DEBUG=""

    # ... run
    run d "this str should not be in output"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ "$output" == "" ]]
}

@test "d has output if DEBUG set to non-empty value" {
    # ... setup
    export DEBUG=true

    # ... run
    run d "this str should be output"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    echo $output | grep -q "this str should be output"
}

@test "d has output even if DEBUG set to whitespace" {
    # ... setup
    export DEBUG=" "

    # ... run
    run d "this str should be output"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    echo $output | grep -q "this str should be output"
}

@test "d has no output if QUIET set even if DEBUG is set" {
    # ... setup
    export DEBUG="true" QUIET="true"

    # ... run
    run d "this str should not be output"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ "$output" == "" ]]
}

@test "d will render actual newlines when passed multiple lines" {
    # ... setup
    export DEBUG=true
    msg="before 1st new line.
        before 2nd new line.
        before 3nd new line."

    # ... run
    run d "$msg"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $(echo "$output" | wc -l) -eq 3 ]]

}

@test "d will render slash-n as actual newlines" {
    # ... setup
    export DEBUG=true
    msg="before 1st new line.\nbefore 2nd new line.\nbefore 3nd new line."

    # ... run
    run d "$msg"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $(echo "$output" | wc -l) -eq 3 ]]

}

@test "d will render mix of actual newlines and slash-n as actual newlines" {
    # ... setup
    export DEBUG=true
    msg="before 1st new line.\nbefore 2nd new line.
        before 3nd new line."

    # ... run
    run d "$msg"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $(echo "$output" | wc -l) -eq 3 ]]

}
