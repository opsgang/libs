#!/usr/bin/env bats
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#
# For functions that don't need or can't meaningfully have tests.
# We still want to ensure they exist in the lib and that if we
# deprecate or remove one we consciously amend the test accordingly.
#
print_on_err() {
    echo "START OUTPUT--|$output|--END OUTPUT"
    echo "status: $status"
}

setup() {
    . habitual/std.functions || return 1
}

@test "safe_chars_def_list exists" {
    # ... run
    run safe_chars_def_list
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
}

@test "random_str exists" {
    run random_str
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
}
