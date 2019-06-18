#!/usr/bin/env bats
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#

load git

@test "git_branch fails if run against a non-git dir" {

    # ... setup - working dir is non-git dir
    mkdir -p $TMPDIR/foo ; cd $TMPDIR/foo

    # ... run
    run git_branch
    print_on_err

    # ... verify
    [[ $status -ne 0 ]]
    echo $output | grep -q 'not in a git repo'
}

@test "git_branch shows branch name even if head commit tagged" {

    # ... setup - create a tag on new branch
    use_test_repo_copy
    git checkout -b $NEW_BRANCH &>/dev/null
    git tag -a "$NEW_TAG" -m 'bah'

    # ... run
    run git_branch
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == $NEW_BRANCH ]]
}

@test "git_branch shows nothing if tag checked out" {

    # ... setup - tag a new branch, move ahead a commit
    # then check out created tag to be sure we are getting
    # value of tag not HEAD.
    use_test_repo_copy
    git checkout -b $NEW_BRANCH &>/dev/null
    git tag -a "$NEW_TAG" -m 'bah'
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    git checkout $NEW_TAG

    # ... run
    run git_branch
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "" ]]
}
