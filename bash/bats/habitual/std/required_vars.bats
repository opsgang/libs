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

@test "required_vars success if all vars exist" {
    # ... setup
    local my_var1=apple my_var2=banana my_var3=carrot

    # ... run
    run required_vars "my_var1 my_var2 my_var3"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
}

@test "required_vars fails if any var missing" {
    # ... setup
    local my_var1=apple my_var2=banana 

    # ... run
    run required_vars "my_var1 my_var2 my_var3"
    print_on_err

    # ... verify
    [[ $status -ne 0 ]]
    echo $output | grep -q 'following vars must be set.*$my_var3'
}
