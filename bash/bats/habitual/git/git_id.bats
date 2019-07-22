#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#

load git

@test "git_id fails without output if not a git repo" {

    # ... setup - working dir is non-git dir
    mkdir -p $TMPDIR/foo ; cd $TMPDIR/foo
    rm $TMPDIR/.gitconfig || true

    # ... run
    run git_id
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    [[ $output == "" ]]
}

@test "git_id outputs git user and email" {
    # ... setup
    use_test_repo_copy

    # ... run
    run git_id
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "$_GIT_USER $_GIT_EMAIL" ]]
}

@test "git_id fails if git_user returns empty" {
    # ... setup
    use_test_repo_copy
    git_user() { echo "" ; }

    # ... run
    run git_id
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    [[ $output == "" ]]
}

@test "git_id returns space separated strings" {
    # ... setup
    use_test_repo_copy

    # ... run
    read -r a b <<< $(git_id)
    print_on_err

    # ... verify
    [[ $a == $_GIT_USER ]]
    [[ $b == $_GIT_EMAIL ]]
}

