setup() {
    . habitual/std.functions || return 1
    . habitual/git.functions || return 1

    export TMPDIR=$BATS_TMPDIR/$BATS_TEST_NAME
    mkdir -p $TMPDIR || true

    export GIT_REPO_URL="https://github.com/opsgang/libs"

    export TMPL_REPO="/var/tmp/opsgang/libs/repo"
    if [[ ! -d $TMPL_REPO ]] || [[ ! -r $TMPL_REPO ]]; then
        echo >&2 "ERROR: $TMPL_REPO is not readable directory"
        return 1
    fi

    export TEST_REPO="$TMPDIR/repo"

    export _GIT_USER="boo"
    export _GIT_EMAIL="boo@boo.com"  

    export NEW_BRANCH="new-branch"
    export NEW_TAG="new-tag"

    # ... set so that git does not use any global .gitconfig
    export HOME=$TMPDIR

    cat <<EOF >$HOME/.gitconfig
[user]
    name = $_GIT_USER
    email = $_GIT_EMAIL
EOF


}

export_shas() {
    HEAD_SHA=$(git log --format='%H' | head -n 1)
    SECOND_SHA=$(git log --format='%H' | sed -n '2p')
    export HEAD_SHA SECOND_SHA
}

teardown() {
    rm -rf $BATS_TMPDIR/$BATS_TEST_NAME || true
}

print_on_err() {
    local mode="$1"
    if [[ "$mode" == "git_vars" ]]; then
        echo "GIT_BRANCH:[${GIT_BRANCH:-not set}]"
        echo "GIT_TAG:[${GIT_TAG:-not set}]"
        echo "GIT_SHA:[${GIT_SHA:-not set}]"
        echo "GIT_USER:[${GIT_USER:-not set}]"
        echo "GIT_EMAIL:[${GIT_EMAIL:-not set}]"
        echo "GIT_ID:[${GIT_ID:-not set}]"
        echo "GIT_INFO:[${GIT_INFO:-not set}]"
        echo "EXP PATTERN:[$rx]"
        echo "status: ${rc:-unknown}"
    elif [[ "$mode" =~ ^git_(branch|tag|sha|user|email|id)$ ]]; then
        local var="${mode^^}" ; local val="${!var}"
        echo "${var}:[${val:-not set}]"
        echo "EXP PATTERN:[$rx]"
        echo "status: ${rc:-unknown}"
    else
        echo "START OUTPUT--|$output|--END OUTPUT"
        echo "status: $status"
    fi
}

use_test_repo_copy() {
    cp -r $TMPL_REPO $TMPDIR
    cd $TEST_REPO
    git reset --hard &>/dev/null || true
}

