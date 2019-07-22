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

@test "semver_a_ge_b fails if a is not a semver" {
    # ... setup
    a="foobar"
    b="1.0.0"

    # ... run
    run semver_a_ge_b "$a" "$b"
    print_on_err

    # ... verify
    [[ $status -eq 2 ]]
    echo $output | grep -q 'expects 2 semver strs as params'
}

@test "semver_a_ge_b fails if b is not a semver" {
    # ... setup
    a="1.0.0"
    b="invalid_semver-1.0.0"

    # ... run
    run semver_a_ge_b "$a" "$b"
    print_on_err

    # ... verify
    [[ $status -eq 2 ]]
    echo $output | grep -q 'expects 2 semver strs as params'
}

@test "semver_a_ge_b fails with no args " {
    # ... run
    run semver_a_ge_b
    print_on_err

    # ... verify
    [[ $status -eq 2 ]]
    echo $output | grep -q 'expects 2 semver strs as params'
}

@test "semver_a_ge_b fails with only 1 arg" {
    # ... run
    run semver_a_ge_b "1.0.0"
    print_on_err

    # ... verify
    [[ $status -eq 2 ]]
    echo $output | grep -q 'expects 2 semver strs as params'
}

@test "semver_a_ge_b succeeds if a > b #1" {
    # ... setup
    a="1.0.0"
    b="0.11.0"

    # ... run
    run semver_a_ge_b "$a" "$b"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
}

@test "semver_a_ge_b succeeds if a > b #2" {
    # ... setup
    a="11.0.0"
    b="9.15.0"

    # ... run
    run semver_a_ge_b "$a" "$b"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
}

@test "semver_a_ge_b succeeds if a == b" {
    # ... setup
    a="3.20.100"
    b="$a"

    # ... run
    run semver_a_ge_b "$a" "$b"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
}

@test "semver_a_ge_b succeeds even if a has leading 'v'" {
    # ... setup
    a="v3.20.100"
    b="1.2.30"

    # ... run
    run semver_a_ge_b "$a" "$b"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
}

@test "semver_a_ge_b succeeds even if b has leading 'v'" {
    # ... setup
    a="3.20.100"
    b="v1.2.30"

    # ... run
    run semver_a_ge_b "$a" "$b"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
}

@test "semver_a_ge_b succeeds even if a has leading 'V'" {
    # ... setup
    a="V3.20.100"
    b="1.2.30"

    # ... run
    run semver_a_ge_b "$a" "$b"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
}

@test "semver_a_ge_b succeeds even if b has leading 'V'" {
    # ... setup
    a="3.20.100"
    b="V1.2.30"

    # ... run
    run semver_a_ge_b "$a" "$b"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
}

@test "semver_a_ge_b succeeds even if a has 'v' and b has 'V'" {
    # ... setup
    a="v3.20.100"
    b="V1.2.30"

    # ... run
    run semver_a_ge_b "$a" "$b"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
}

@test "semver_a_ge_b succeeds even if a has 'V' and b has 'v'" {
    # ... setup
    a="V3.20.100"
    b="v1.2.30"

    # ... run
    run semver_a_ge_b "$a" "$b"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
}

@test "semver_a_ge_b succeeds if a is prerelease but newer version than b" {
    # ... setup
    a="1.0.1-not-ready-for-use"
    b="1.0.0"

    # ... run
    run semver_a_ge_b "$a" "$b"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
}

@test "semver_a_ge_b returns false if a is prerelease but same version as b" {
    # ... setup
    a="1.0.0-not-ready-for-use"
    b="1.0.0"

    # ... run
    run semver_a_ge_b "$a" "$b"
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    [[ $output == "" ]]
}

@test "semver_a_ge_b returns false if a is prerelease, same version fewer subparts" {
    # ... setup
    a="1.0.0-not-ready-for-use.but.wait.a.bit"
    b="1.0.0-not-ready-for-use.but.wait.a.bit.longer"

    # ... run
    run semver_a_ge_b "$a" "$b"
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    [[ $output == "" ]]
}

@test "semver_a_ge_b returns true if a is prerelease, same version more subparts" {
    # ... setup
    a="1.0.0-not-ready-for-use.but.wait.a.bit.longer"
    b="1.0.0-not-ready-for-use.but.wait.a.bit"

    # ... run
    run semver_a_ge_b "$a" "$b"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "" ]]
}

@test "semver_a_ge_b returns true if a is prerelease, higher precedence subparts" {
    # ... setup
    a="1.0.0-not-ready-for-use.beta"
    b="1.0.0-not-ready-for-use.alpha"

    # ... run
    run semver_a_ge_b "$a" "$b"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "" ]]
}

@test "semver_a_ge_b ignores build metadata for precedence #1" {
    # ... setup
    a="1.0.0+alpha"
    b="1.0.0+beta.but.build.metadata.should.be.ignored"

    # ... run
    run semver_a_ge_b "$a" "$b"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "" ]]
}

@test "semver_a_ge_b ignores build metadata for precedence #2" {
    # ... setup
    a="1.0.0-a+alpha"
    b="1.0.0-a+beta"

    # ... run
    run semver_a_ge_b "$a" "$b"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "" ]]
}

@test "semver_a_ge_b ascii prerelease beats numeric prerelease" {
    # ... setup
    a="1.0.0-a"
    b="1.0.0-100.10.1"

    # ... run
    run semver_a_ge_b "$a" "$b"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "" ]]
}

@test "semver_a_ge_b numeric prereleases compared as numbers" {
    # ... setup
    a="1.0.0-1.10.2"
    b="1.0.0-1.2.10"

    # ... run
    run semver_a_ge_b "$a" "$b"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "" ]]
}

@test "semver_a_ge_b numeric prereleases compared as numbers unless a leading 0" {
    # ... setup
    a="1.0.0-1.020.2" # not numeric sort as leading zero in '020'
    b="1.0.0-1.2.10"

    # ... run
    run semver_a_ge_b "$a" "$b"
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    [[ $output == "" ]]
}
