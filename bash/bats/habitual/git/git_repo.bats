#!/usr/bin/env bats
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#

load git

@test "git_repo succeeds but outputs nothing if pwd is not a git repo" {

    # ... setup - working dir is non-git dir
    mkdir -p $TMPDIR/foo ; cd $TMPDIR/foo

    # ... run
    run git_repo
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "" ]]
}

@test "git_repo succeeds if in a git repo root dir" {

    # ... setup
    use_test_repo_copy

    # ... run
    run git_repo
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == $GIT_REPO_URL ]]
}

@test "git_repo succeeds if in a git repo sub dir" {

    # ... setup
    use_test_repo_copy
    mkdir -p foo/bar ; cd foo/bar

    # ... run
    run git_repo
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == $GIT_REPO_URL ]]
}
