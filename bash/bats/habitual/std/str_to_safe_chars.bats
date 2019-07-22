#!/usr/bin/env bats
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#
print_on_err() {
    echo -e "START OUTPUT--|$output|--END OUTPUT"
    if [[ ! -z "$EXPECTED_STR" ]]; then
        [[ -z "$result_str_len" ]] || echo -e " (len: $result_str_len)\n"
        echo "EXPECTED    --|$EXPECTED_STR|--END OUTPUT (len: $EXPECTED_STR_LEN)"
    else
        echo -e "\n"
    fi
    echo "status: $status"
}

setup() {

    export STR_ASCII="$(ascii_chars)"
    export SAFE_AWS_CHARS='[:alnum:]:_.=+@/-'
    
    e="___________+_-./0123456789"
    e="${e}:__=__@ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    e="${e}______abcdefghijklmnopqrstuvwxyz______@"

    export EXPECTED_STR="$e"
    export EXPECTED_STR_LEN="${#EXPECTED_STR}"


    export UTF8_ACUTE_E="$(printf '\xC3\xA9')" # e with acute accent

    export STR_UTF8_FLATTENED="cafe attache mate trema"
    _e="$UTF8_ACUTE_E" ; STR_UTF8="caf$_e attach$_e mat$_e tr${_e}ma"
    export STR_UTF8

    . habitual/std.functions || return 1
}

set_posix() {
    loc="POSIX"
    export LC_ALL="$loc" LC_CTYPE="$loc" LANG="$loc" LANGUAGE="$loc"
}

set_utf8() {
    loc="en_US.UTF-8"
    export LC_ALL="$loc" LC_CTYPE="$loc" LANG="$loc" LANGUAGE="$loc"
}

ascii_chars() {
    for((i=32;i<=127;i++)) do
        printf \\$(printf '%03o\t' "$i")
    done
    printf " @\n" # add space to set of ascii chars, with additional at symbol
                  # just so we know where to look in related test failures.
}

@test "str_to_safe_chars default replacement str is underscore" {
    # ... setup
    set_posix
    
    # ... run
    run str_to_safe_chars "$STR_ASCII"
    result_str_len="${#output}"

    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ "$output" == "$EXPECTED_STR" ]]
    [[ $result_str_len -eq $EXPECTED_STR_LEN ]]
}

no_success_output_expected() {
    unset EXPECTED_STR
    unset EXPECTED_STR_LEN
}

@test "str_to_safe_chars fails if replacement str is too long" {
    # ... setup
    set_posix
    no_success_output_expected
    
    # ... run
    run str_to_safe_chars "some string" "__"
    print_on_err

    # ... verify
    [[ $status -ne 0 ]]
    echo $output | grep -q 'replacement must be one UTF-8 char'
}

@test "str_to_safe_chars can create safe aws tag" {
    # ... setup
    set_posix
    
    # ... run
    run str_to_safe_chars "$STR_ASCII" "_" "$SAFE_AWS_CHARS"
    result_str_len="${#output}"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ "$output" == "$EXPECTED_STR" ]]
    [[ $result_str_len -eq $EXPECTED_STR_LEN ]]
}

@test "str_to_safe_chars disallowed chars set not including exclamation" {
    # ... setup
    set_posix
    EXPECTED_STR='apple____' ; EXPECTED_STR_LEN="${#EXPECTED_STR}"
    STR_ASCII='apple!$*&'
    ONLY_REPLACE_THESE_CHARS='![:punct:][:blank:]'
    
    # ... run
    run str_to_safe_chars "$STR_ASCII" "_" "$SAFE_AWS_CHARS"
    result_str_len="${#output}"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ "$output" == "$EXPECTED_STR" ]]
    [[ $result_str_len -eq $EXPECTED_STR_LEN ]]
}

@test "str_to_safe_chars disallowed chars set including ! as 1st of set" {
    # ... setup
    set_posix
    EXPECTED_STR='apple_$_&_' ; EXPECTED_STR_LEN="${#EXPECTED_STR}"
    STR_ASCII='apple!$*& '
    ONLY_REPLACE_THESE_CHARS='!!*[:blank:]'
    
    # ... run
    run str_to_safe_chars "$STR_ASCII" "_" "$ONLY_REPLACE_THESE_CHARS"
    result_str_len="${#output}"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ "$output" == "$EXPECTED_STR" ]]
    [[ $result_str_len -eq $EXPECTED_STR_LEN ]]
}

@test "str_to_safe_chars disallowed chars set including ! not first in set" {
    # ... setup
    set_posix
    STR_ASCII='apple!$*& '
    EXPECTED_STR='apple_$_&_' ; EXPECTED_STR_LEN="${#EXPECTED_STR}"
    ONLY_REPLACE_THESE_CHARS='!*![:blank:]'
    
    # ... run
    run str_to_safe_chars "$STR_ASCII" "_" "$ONLY_REPLACE_THESE_CHARS"
    result_str_len="${#output}"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ "$output" == "$EXPECTED_STR" ]]
    [[ $result_str_len -eq $EXPECTED_STR_LEN ]]
}

@test "str_to_safe_chars replace ascii e with utf8 acute e" {
    # ... setup
    set_utf8
    EXPECTED_STR="$STR_UTF8" ; EXPECTED_STR_LEN="${#EXPECTED_STR}"
    
    # ... run
    run str_to_safe_chars "$STR_UTF8_FLATTENED" "$UTF8_ACUTE_E" '!e'
    result_str_len="${#output}"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ "$output" == "$EXPECTED_STR" ]]
    [[ $result_str_len -eq $EXPECTED_STR_LEN ]]
}

@test "str_to_safe_chars replace utf8 acute e with normal e" {
    # ... setup
    set_utf8
    EXPECTED_STR="$STR_UTF8_FLATTENED" ; EXPECTED_STR_LEN="${#EXPECTED_STR}"
    
    # ... run
    run str_to_safe_chars "$STR_UTF8" "e" "!$UTF8_ACUTE_E"
    result_str_len="${#output}"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ "$output" == "$EXPECTED_STR" ]]
    [[ $result_str_len -eq $EXPECTED_STR_LEN ]]
}

@test "str_to_safe_chars fails with utf8 replacement with wrong locale" {
    # ... setup
    no_success_output_expected
    set_posix
    
    # ... run
    run str_to_safe_chars "$STR_UTF8_FLATTENED" "$UTF8_ACUTE_E" '!e'
    print_on_err

    # ... verify
    [[ $status -ne 0 ]]
    echo $output | grep -iq 'set the correct locale'
}

@test "str_to_safe_chars transforms utf8 char wrongly if using the wrong locale" {
    # ... setup
    set_posix
    EXPECTED_STR='cafee attachee matee treema'
    EXPECTED_STR_LEN="${#EXPECTED_STR}" 
    # ... run
    run str_to_safe_chars "$STR_UTF8" 'e' "!${UTF8_ACUTE_E}"
    result_str_len="${#output}"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ "$output" == "$EXPECTED_STR" ]]
    [[ $result_str_len -eq $EXPECTED_STR_LEN ]]
}
