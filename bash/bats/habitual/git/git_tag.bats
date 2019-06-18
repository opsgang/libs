#!/usr/bin/env bats
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#

load git

@test "git_tag succeeds, but no output if not a git repo" {

    # ... setup - working dir is non-git dir
    mkdir -p $TMPDIR/foo ; cd $TMPDIR/foo

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "" ]]
}

@test "git_tag outputs annotated tag name at HEAD" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    git tag -a $NEW_TAG -m 'bah'

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == $NEW_TAG ]]
}

@test "git_tag outputs nothing if no tag on HEAD commit" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "" ]]
}

@test "git_tag outputs lightweight tag at HEAD" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    git tag $NEW_TAG

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == $NEW_TAG ]]
}

@test "git_tag outputs in alphanumeric sort order when multiple lightweight" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    git tag "${NEW_TAG}-top"
    git tag "${NEW_TAG}-001"
    git tag "${NEW_TAG}-stetson"
    git tag "${NEW_TAG}-apple"
    git tag "${NEW_TAG}-fedora"

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == $NEW_TAG-001 ]]
}

@test "git_tag outputs in alphanumeric sort order when multiple annotated" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    git tag -a "${NEW_TAG}-top" -m 'bah'
    git tag -a "${NEW_TAG}-apple" -m 'bah'
    git tag -a "${NEW_TAG}-001" -m 'bah'
    git tag -a "${NEW_TAG}-stetson" -m 'bah'
    git tag -a "${NEW_TAG}-fedora" -m 'bah'

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == $NEW_TAG-001 ]]
}

@test "git_tag prefers annotated tag first in \w+ in sort order and ignores light #1" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    git tag "${NEW_TAG}-top"
    git tag -a "${NEW_TAG}-apple" -m 'bah'
    git tag -a "${NEW_TAG}-001" -m 'bah'
    git tag "${NEW_TAG}-002"
    git tag -a "${NEW_TAG}-fedora" -m 'bah'

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == $NEW_TAG-001 ]]
}

@test "git_tag prefers annotated tag first in \w+ in sort order and ignores light #2" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    git tag "${NEW_TAG}-top"
    git tag -a "${NEW_TAG}-apple" -m 'bah'
    git tag "${NEW_TAG}-001"
    git tag "${NEW_TAG}-002"
    git tag -a "${NEW_TAG}-003" -m 'bah'
    git tag -a "${NEW_TAG}-fedora" -m 'bah'

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == $NEW_TAG-003 ]]
}

