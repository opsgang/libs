#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#

load git

@test "sha_in_origin takes sha as user passed arg" {
    # ... setup
    sha=made-up-sha

    # ... run
    run sha_in_origin $sha
    print_on_err

    # ... verify
    echo $output | grep -q "checking git sha $sha exists in origin"
}

@test "sha_in_origin takes GIT_SHA if set and arg not passed" {
    # ... setup
    sha='GIT_SHA-set-in-env-no-arg'
    export GIT_SHA="$sha"

    # ... run
    run sha_in_origin 
    print_on_err

    # ... verify
    echo $output | grep -q "checking git sha $sha exists in origin"
}

@test "sha_in_origin takes current sha val if GIT_SHA not set and arg not passed" {
    # ... setup
    use_test_repo_copy
    export_shas
    sha="${HEAD_SHA:0:$GIT_SHA_LEN}"

    # ... run
    run sha_in_origin 
    print_on_err

    # ... verify
    echo $output | grep -q "checking git sha $sha exists in origin"
}

@test "sha_in_origin prefers user-passed sha" {
    # ... setup
    use_test_repo_copy
    export GIT_SHA="should-not-be-used"
    sha="should-be-preferred"

    # ... run
    run sha_in_origin "$sha"
    print_on_err

    # ... verify
    echo $output | grep -q "checking git sha $sha exists in origin"
}

@test "sha_in_origin prefers GIT_SHA if no arg passed" {
    # ... setup
    use_test_repo_copy
    sha="should-be-preferred"
    export GIT_SHA="$sha"

    # ... run
    run sha_in_origin
    print_on_err

    # ... verify
    echo $output | grep -q "checking git sha $sha exists in origin"
}

@test "sha_in_origin fails if no arg and GIT_SHA not set and not in git repo" {
    # ... setup
    dir="$TMPDIR/not-a-git-dir"
    mkdir -p $dir
    cd $dir

    # ... run
    run sha_in_origin
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    echo $output | grep -q 'no git_sha passed as param, or $GIT_SHA or sha'
}

@test "sha_in_origin uses GIT_SHA if user passes empty string" {
    # ... setup
    use_test_repo_copy
    sha=""
    export GIT_SHA="will-use-this"

    # ... run
    run sha_in_origin "$sha"
    print_on_err

    # ... verify
    echo $output | grep -q "checking git sha $GIT_SHA exists in origin"
}

@test "sha_in_origin uses current sha if GIT_SHA and user-passed arg are empty strs" {
    # ... setup
    use_test_repo_copy
    export_shas
    real_sha="${HEAD_SHA:0:$GIT_SHA_LEN}"
    sha=""
    export GIT_SHA=""

    # ... run
    run sha_in_origin "$sha"
    print_on_err

    # ... verify
    echo $output | grep -q "checking git sha $real_sha exists in origin"
}

@test "sha_in_origin fails if sha not in origin" {
    # ... setup
    use_test_repo_copy

    git checkout -b $NEW_BRANCH &>/dev/null
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    export_shas

    sha="${HEAD_SHA:0:$GIT_SHA_LEN}"

    # ... run
    run sha_in_origin
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    echo $output | grep -q "($sha) does not exist on origin"
}

@test "sha_in_origin succeeds if detached head but in origin" {
    # ... setup
    use_test_repo_copy

    git checkout -b $NEW_BRANCH &>/dev/null
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    export_shas

    git checkout $SECOND_SHA &>/dev/null # detached head
    sha="${SECOND_SHA:0:$GIT_SHA_LEN}"

    # ... run
    run sha_in_origin
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    echo $output | grep -q "checking git sha $sha exists in origin"
    echo $output | grep -q 'all looking copacetic'
}
