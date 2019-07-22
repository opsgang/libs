#!/usr/bin/env bats
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#

load git

@test "in_git_clone fails with no arg if current dir is not a git dir" {

    # ... setup - working dir is non-git dir
    mkdir -p $TMPDIR/foo ; cd $TMPDIR/foo

    # ... run
    run in_git_clone
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
}

@test "in_git_clone succeeds with no arg if current dir *is* a git dir" {

    # ... setup
    use_test_repo_copy

    # ... run
    run in_git_clone
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
}

@test "in_git_clone fails if empty str used and pwd is not a git dir" {

    # ... setup - working dir is non-git dir
    mkdir -p $TMPDIR/foo ; cd $TMPDIR/foo

    # ... run
    run in_git_clone ""
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
}

@test "in_git_clone succeeds if empty str used and pwd *is* a git dir" {

    # ... setup
    use_test_repo_copy

    # ... run
    run in_git_clone ""
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
}

# ... can't use bats' run func when proving in_git_clone leaves user
# in the starting dir, because that creates a subshell.
# A subshell will return user to current dir anyway after completion.
@test "in_git_clone does not leave user in different pwd" {
    # ... setup
    current_dir=$(pwd) ; 
    print_on_err
    use_test_repo_copy ; cd $current_dir

    # ... run
    in_git_clone $TMPDIR/repo

    # ... verify
    [[ $? -eq 0 ]]
    [[ "$(pwd)" == "$current_dir" ]]
}

