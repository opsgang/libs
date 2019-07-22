#!/usr/bin/env bats
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#

load git

@test "git_vars fails if pwd is not a git repo" {

    # ... setup - working dir is non-git dir
    mkdir -p $TMPDIR/foo ; cd $TMPDIR/foo

    # ... run
    run git_vars
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    echo $output | grep -q 'is not inside a git repo'
}

@test "git_vars fails if git_branch() fails" {

    # ... setup
    use_test_repo_copy
    git_branch() { return 1; }

    # ... run
    run git_vars
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
}

# ... create known branch and tag state
# Can't use run func as that creates a subshell so
# exported GIT_INFO would be lost to outer shell.
#
# We can't know the sha1 with out basically adding a test
# function that is ultimately the same as one of the functions
# under test, so we will leave that testing to the git_sha() tests.
@test "git_vars exports a GIT_INFO str" {

    # ... setup
    use_test_repo_copy
    unset GIT_INFO
    rx="repo:$GIT_REPO_URL sha1:\w+ tag:$NEW_TAG branch:$NEW_BRANCH" 

    git checkout -b $NEW_BRANCH &>/dev/null
    git tag -a "$NEW_TAG" -m 'bah'

    # ... run
    git_vars # exports GIT_INFO to this shell.
    rc=$?
    print_on_err git_vars

    # ... verify
    [[ $rc -eq 0 ]]
    echo "$GIT_INFO" | grep -Pq "$rx"
}

@test "git_vars exports a GIT_BRANCH" {

    # ... setup
    use_test_repo_copy
    unset GIT_BRANCH
    rx="^$NEW_BRANCH$"

    git checkout -b $NEW_BRANCH &>/dev/null
    git tag -a "$NEW_TAG" -m 'bah'

    # ... run
    git_vars # exports GIT_INFO to this shell.
    rc=$?
    print_on_err git_vars

    # ... verify
    [[ $rc -eq 0 ]]
    echo "$GIT_BRANCH" | grep -q "$rx"
}

@test "git_vars exports a GIT_TAG" {

    # ... setup
    use_test_repo_copy
    unset GIT_TAG
    rx="^$NEW_TAG$"

    git checkout -b $NEW_BRANCH &>/dev/null
    git tag -a "$NEW_TAG" -m 'bah'

    # ... run
    git_vars # exports GIT_INFO to this shell.
    rc=$?
    print_on_err git_vars

    # ... verify
    [[ $rc -eq 0 ]]
    echo "$GIT_TAG" | grep -q "$rx"
}

@test "git_vars exports a GIT_SHA" {

    # ... setup
    use_test_repo_copy
    unset GIT_SHA
    rx="^\w+$"

    git checkout -b $NEW_BRANCH &>/dev/null
    git tag -a "$NEW_TAG" -m 'bah'

    # ... run
    git_vars # exports GIT_INFO to this shell.
    rc=$?
    print_on_err git_vars

    # ... verify
    [[ $rc -eq 0 ]]
    echo "$GIT_SHA" | grep -Pq "$rx"
}

@test "git_vars exports a GIT_USER" {

    # ... setup
    use_test_repo_copy
    unset GIT_USER
    rx="^$_GIT_USER$"

    git checkout -b $NEW_BRANCH &>/dev/null
    git tag -a "$NEW_TAG" -m 'bah'

    # ... run
    git_vars # exports GIT_INFO to this shell.
    rc=$?
    print_on_err git_vars

    # ... verify
    [[ $rc -eq 0 ]]
    echo "$GIT_USER" | grep -Pq "$rx"
}

@test "git_vars exports a GIT_EMAIL" {

    # ... setup
    use_test_repo_copy
    unset GIT_EMAIL
    rx="^$_GIT_EMAIL$"

    git checkout -b $NEW_BRANCH &>/dev/null
    git tag -a "$NEW_TAG" -m 'bah'

    # ... run
    git_vars # exports GIT_INFO to this shell.
    rc=$?
    print_on_err git_vars

    # ... verify
    [[ $rc -eq 0 ]]
    echo "$GIT_EMAIL" | grep -Pq "$rx"
}

@test "git_vars exports a GIT_ID" {

    # ... setup
    use_test_repo_copy
    unset GIT_ID
    rx="^$_GIT_USER $_GIT_EMAIL$"

    git checkout -b $NEW_BRANCH &>/dev/null
    git tag -a "$NEW_TAG" -m 'bah'

    # ... run
    git_vars # exports GIT_INFO to this shell.
    rc=$?
    print_on_err git_vars

    # ... verify
    [[ $rc -eq 0 ]]
    echo "$GIT_ID" | grep -Pq "$rx"
}
