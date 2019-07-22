#!/usr/bin/env bats
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#
print_on_err() {
    echo "START OUTPUT--|$output|--END OUTPUT"
    echo "status: $status"
}

setup() {
    unset BUILD_URL
    . habitual/std.functions || return 1
}

@test "export_build_url fails if no build url can be determined" {
    # ... run
    run export_build_url
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
}

@test "export_build_url honours BUILD_URL" {
    # ... setup
    DEBUG=true
    BUILD_URL="https://example.com/foo/bar/1"
    url="$BUILD_URL"

    # ... run
    run export_build_url
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    echo $output | grep -q "BUILD_URL.*$url"
}

@test "export_build_url honours CIRCLE_BUILD_URL" {
    # ... setup
    DEBUG=true
    CIRCLE_BUILD_URL="should use this value"
    BUILD_URL="should not be used"

    url="$CIRCLE_BUILD_URL"

    # ... run
    run export_build_url
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    echo $output | grep -q "BUILD_URL.*$url"
}

@test "export_build_url honours TRAVIS_JOB_WEB_BUILD_URL" {
    # ... setup
    DEBUG=true
    TRAVIS_JOB_WEB_URL="should use travis value"
    BUILD_URL="should not be used"

    url="$TRAVIS_JOB_WEB_URL"

    # ... run
    run export_build_url
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    echo $output | grep -q "BUILD_URL.*$url"
}

@test "export_build_url honours CI_BUILD_URL" {
    # ... setup
    DEBUG=true
    CI_BUILD_URL="should use this codeship-compatible val"
    BUILD_URL="should not be used"

    url="$CI_BUILD_URL"

    # ... run
    run export_build_url
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    echo $output | grep -q "BUILD_URL.*$url"
}
