#!/usr/bin/env bats
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#

load git

@test "git_sha fails with git err if not a git repo" {

    # ... setup - working dir is non-git dir
    mkdir -p $TMPDIR/foo ; cd $TMPDIR/foo

    # ... run
    run git_sha
    print_on_err

    # ... verify
    [[ $status -ne 0 ]]
    [[ $output =~ "fatal: not a git repository" ]]
}

@test "git_sha outputs current commit sha on non-detached head" {
    # ... setup
    use_test_repo_copy
    git checkout -b $NEW_BRANCH &>/dev/null
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    export_shas

    # ... run
    run git_sha
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $HEAD_SHA =~ ^$output ]]
}

@test "git_sha outputs current commit sha even on detached head" {
    # ... setup
    use_test_repo_copy
    export_shas
    git checkout $SECOND_SHA &>/dev/null

    # ... run
    run git_sha
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $SECOND_SHA =~ ^$output ]]
}

@test "git_sha honours GIT_SHA_LEN" {
    # ... setup
    use_test_repo_copy
    MY_GIT_SHA_LEN=6
    export GIT_SHA_LEN=$MY_GIT_SHA_LEN
    export_shas

    # ... run
    run git_sha
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $HEAD_SHA =~ ^$output ]]
    [[ ${#output} -eq $MY_GIT_SHA_LEN ]]
}
