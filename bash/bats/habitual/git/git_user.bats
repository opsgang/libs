#!/usr/bin/env bats
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#

load git

@test "git_user fails without output if not a git repo" {

    # ... setup - working dir is non-git dir
    mkdir -p $TMPDIR/foo ; cd $TMPDIR/foo
    rm $TMPDIR/.gitconfig || true

    # ... run
    run git_user
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    [[ $output == "" ]]
}

@test "git_user outputs user.name in git repo if set" {
    # ... setup
    use_test_repo_copy

    # ... run
    run git_user
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == $_GIT_USER ]]
}

@test "git_user fails and outputs nothing in git repo if user unset" {
    # ... setup
    use_test_repo_copy
    rm $TMPDIR/.gitconfig || true

    # ... run
    run git_user
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    [[ $output == "" ]]
}
