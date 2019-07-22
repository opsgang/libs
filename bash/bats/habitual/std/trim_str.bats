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

@test "trim_str removes leading whitespace" {
    # ... setup
    str="  leading spaces"

    # ... run
    run std::trim_str "$str"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ "$output" == "leading spaces" ]]
}

@test "trim_str removes trailing whitespace" {
    # ... setup
    str="trailing spaces   "

    # ... run
    run std::trim_str "$str"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ "$output" == "trailing spaces" ]]
}

@test "trim_str only changes trailing and leading whitespace" {
    # ... setup
    str="no trailing  or    leading spaces"

    # ... run
    run std::trim_str "$str"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ "$output" == "no trailing  or    leading spaces" ]]
}

@test "trim_str removes leading or trailing tabs" {
    # ... setup
    str=$(echo -e "\t remove leading and trailing tabs too\t ")

    # ... run
    run std::trim_str "$str"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ "$output" == "remove leading and trailing tabs too" ]]
}

@test "trim_str removes leading or trailing newlines" {
    # ... setup
    str=$(echo -e "\n \n remove leading and trailing newlines too \n\n ")

    # ... run
    run std::trim_str "$str"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ "$output" == "remove leading and trailing newlines too" ]]
}
