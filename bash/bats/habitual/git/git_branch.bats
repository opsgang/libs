#!/usr/bin/env bats
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#

# ... always run this code at test startup 
create_tmpl_repo() {
    local tmpl_repo="/var/tmp/opsgang/libs/repo"
    local src_repo_url="https://github.com/opsgang/libs"

    [[ -d $tmpl_repo ]] && return 0
    mkdir -p $(dirname $tmpl_repo)
    git clone --depth 5 --branch master $src_repo_url $tmpl_repo &>/dev/null
}
create_tmpl_repo || exit 1

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
    HEAD_SHA=$(cd $TMPL_REPO && git log --format='%H' | head -n 1)
    SECOND_SHA=$(cd $TMPL_REPO && git log --format='%H' | sed -n '2p')
    export HEAD_SHA SECOND_SHA

    export TEST_REPO="$TMPDIR/repo"

    export _GIT_USER="boo"
    export _GIT_EMAIL="boo@boo.com"  

    make_test_repo
}

teardown() {
    rm -rf $BATS_TMPDIR/$BATS_TEST_NAME || true
}

make_test_repo() {
    cp -R $TMPL_REPO $TMPDIR
    (
        cd $TEST_REPO
        git reset --hard &>/dev/null
        git config user.name $_USER
        git config user.email $_EMAIL
    )
}

@test "git_branch fails if run against a non-git dir" {

    # ... set up
    mkdir -p $TMPDIR/foo ; cd foo

    # ... run
    run git_branch

    # ... verify
    [[ $status -ne 0 ]]
    echo $output | grep -q 'not in a git repo'
}

@test "git_branch shows branch name even if head commit tagged" {

    export BRANCH_NAME="new-branch"
    export TAG_NAME="new-tag"
    # ... set up
    cd $TEST_REPO
    git --no-pager checkout -b $BRANCH_NAME
    git --no-pager tag -a $TAG_NAME -m 'bah'

    # ... run
    run git_branch

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "new-branch" ]]
}
