#!/usr/bin/env bats
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#

load git

@test "check_for_changes takes dir as arg" {
    # ... setup - starting dir is non-git dir
    dir="$TMPDIR/not-a-git-dir"
    mkdir -p $dir
    use_test_repo_copy
    cd $dir # move out of test repo, so check_for_changes moves to user-specified dir

    # ... run
    run check_for_changes "$TEST_REPO"
    print_on_err

    # ... verify
    echo $output | grep -q "checking for uncommitted changes in $TEST_REPO"
}

@test "check_for_changes defaults to current dir if no arg" {
    # ... setup 
    use_test_repo_copy

    # ... run
    run check_for_changes
    print_on_err

    # ... verify
    echo $output | grep -q "checking for uncommitted changes in $TEST_REPO"
}

@test "check_for_changes fails if dir does not exist" {
    # ... setup
    dir="$TMPDIR/does-not-exist"

    # ... run
    run check_for_changes "$dir"
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    echo $output | grep -q "couldn't cd to $dir"
}

@test "check_for_changes fails if dir not a git dir" {
    # ... setup
    dir="$TMPDIR/not-a-git-dir"
    mkdir -p $dir

    # ... run
    run check_for_changes "$dir"
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    echo $output | grep -q 'not a git dir'
}

@test "check_for_changes passes if no uncommitted changes" {
    # ... setup 
    use_test_repo_copy

    # ... run
    run check_for_changes
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    echo $output | grep -q "checking for uncommitted changes in $TEST_REPO"
    echo $output | grep -q '... none found'
}

@test "check_for_changes fails if git-tracked file modified (no add)" {
    # ... setup 
    use_test_repo_copy
    echo "foo" >> README.md

    # ... run
    run check_for_changes "$TEST_REPO"
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    echo $output | grep -q "local changes in $TEST_REPO"
}

@test "check_for_changes fails if git-tracked file modified (git added)" {
    # ... setup 
    use_test_repo_copy
    echo "foo" >> README.md
    git add README.md

    # ... run
    run check_for_changes "$TEST_REPO"
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    echo $output | grep -q "local changes in $TEST_REPO"
}

@test "check_for_changes fails if git-tracked file deleted (no add)" {
    # ... setup 
    use_test_repo_copy
    rm README.md

    # ... run
    run check_for_changes "$TEST_REPO"
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    echo $output | grep -q "local changes in $TEST_REPO"
}

@test "check_for_changes fails if git-tracked file deleted (git add)" {
    # ... setup 
    use_test_repo_copy
    rm README.md
    git add --all

    # ... run
    run check_for_changes "$TEST_REPO"
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    echo $output | grep -q "local changes in $TEST_REPO"
}

@test "check_for_changes fails if git-tracked file perms changed (no add)" {
    # ... setup 
    use_test_repo_copy
    chmod a+x README.md

    # ... run
    run check_for_changes "$TEST_REPO"
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    echo $output | grep -q "local changes in $TEST_REPO"
}

@test "check_for_changes fails if git-tracked file perms changed (git add)" {
    # ... setup 
    use_test_repo_copy
    chmod a+x README.md
    git add --all

    # ... run
    run check_for_changes "$TEST_REPO"
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    echo $output | grep -q "local changes in $TEST_REPO"
}

@test "check_for_changes succeeds if new file appears (no add)" {
    # ... setup 
    use_test_repo_copy
    echo "foo" > new_file

    # ... run
    run check_for_changes "$TEST_REPO"
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    echo $output | grep -q "none found"
}

@test "check_for_changes fails if new file appears (git added)" {
    # ... setup 
    use_test_repo_copy
    echo "foo" > new_file
    git add new_file

    # ... run
    run check_for_changes "$TEST_REPO"
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    echo $output | grep -q "local changes in $TEST_REPO"
}
