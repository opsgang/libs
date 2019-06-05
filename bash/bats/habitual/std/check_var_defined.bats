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

@test "check_var_defined success if var has a val" {
    my_var="some value"

    run check_var_defined my_var
    print_on_err
    [[ $status -eq 0 ]]
}

@test "check_var_defined fails if empty" {
    my_var=""

    run check_var_defined my_var
    print_on_err
    [[ $status -ne 0 ]]
}

@test "check_var_defined fails if var unser" {
    my_var="some value"
    unset my_var

    run check_var_defined my_var
    print_on_err
    [[ $status -ne 0 ]]
}
