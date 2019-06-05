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

@test "envsubst_tokens_list produces string of tokens as expected" {
    # ... setup
    expected_str='${apple} ${banana} ${carrot}'

    # ... run
    run envsubst_tokens_list 'apple banana carrot'
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ "$output" == "$expected_str" ]]
}

@test "envsubst_tokens_list produces empty str if no arg" {
    # ... run
    run envsubst_tokens_list ''
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ "$output" == "" ]]
}

@test "envsubst_tokens_list outputs empty and err if invalid var names" {
    # ... setup
    expected_invalid='$apple @banana 1date'

    # ... run
    run envsubst_tokens_list '$apple @banana _carrot 1date'
    print_on_err

    # ... verify
    [[ $status -ne 0 ]]
    echo $output | grep -q "following tokens are invalid.*$expected_invalid"
}
