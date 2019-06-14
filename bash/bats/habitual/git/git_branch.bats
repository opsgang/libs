#!/usr/bin/env bats
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#

# TODO: Need to move this in to the test.sh before running bats
# because bats will hang and swallow tests if run concurrently ...
print_on_err() {
    echo "START OUTPUT--|$output|--END OUTPUT"
    echo "status: $status"
}

setup() {
    . habitual/std.functions || return 1
    . habitual/git.functions || return 1

    export TMPDIR=$BATS_TMPDIR/$BATS_TEST_NAME
    mkdir -p $TMPDIR || true

    export TMPL_REPO="/var/tmp/opsgang/libs/repo"
    if [[ ! -d $TMPL_REPO ]] || [[ ! -r $TMPL_REPO ]]; then
        echo >&2 "ERROR: $TMPL_REPO is not readable directory"
        return 1
    fi
    HEAD_SHA=$(cd $TMPL_REPO && git log --format='%H' | head -n 1)
    SECOND_SHA=$(cd $TMPL_REPO && git log --format='%H' | sed -n '2p')
    export HEAD_SHA SECOND_SHA

    export TEST_REPO="$TMPDIR/repo"

    export _GIT_USER="boo"
    export _GIT_EMAIL="boo@boo.com"  
}

teardown() {
    rm -rf $BATS_TMPDIR/$BATS_TEST_NAME || true
}

use_test_repo_copy() {
    cp -r $TMPL_REPO $TMPDIR

    cd $TEST_REPO
    git reset --hard &>/dev/null || true
    git config user.name $_USER
    git config user.email $_EMAIL
}

@test "git_branch fails if run against a non-git dir" {

    # ... set up
    mkdir -p $TMPDIR/foo ; cd $TMPDIR/foo

    # ... run
    run git_branch
    print_on_err

    # ... verify
    [[ $status -ne 0 ]]
    echo $output | grep -q 'not in a git repo'
}

@test "git_branch shows branch name even if head commit tagged" {

    export BRANCH_NAME="new-branch"
    export TAG_NAME="new-tag"
    # ... set up
    use_test_repo_copy &>/dev/null || true
    git --no-pager checkout -b $BRANCH_NAME &>/dev/null
    git --no-pager tag -a $TAG_NAME -m 'bah' &>/dev/null

    # ... run
    run git_branch
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "new-branch" ]]
}
