#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#

load git

@test "git_info_str fails if arg is not a dir" {
    # ... setup
    dir="$TMPDIR/does-not-exist"

    # ... run
    run git_info_str "$dir"
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    echo $output | grep -q "couldn't cd to $dir"
}

@test "git_info_str fails if arg is not a git dir" {
    # ... setup
    dir="$TMPDIR/not-a-git-dir"
    mkdir -p $dir

    # ... run
    run git_info_str "$dir"
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    echo $output | grep -q "not a git dir"
}

@test "git_info_str fails with no args if pwd is not a git repo" {

    # ... setup - working dir is non-git dir
    mkdir -p $TMPDIR/foo ; cd $TMPDIR/foo

    # ... run
    run git_info_str
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    echo $output | grep -q 'not a git dir'
}

@test "git_info_str fails silently if git_branch() fails" {

    # ... setup - working dir is non-git dir
    use_test_repo_copy
    git_branch() { false ; }

    # ... run
    run git_info_str
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    [[ $output == "" ]]
}

@test "git_info_str prints expected format" {
    # ... setup - working dir is non-git dir
    use_test_repo_copy
    git checkout -b $NEW_BRANCH &>/dev/null
    git tag -a "$NEW_TAG" -m 'bah'

    export_shas
    head_sha="${HEAD_SHA:0:$GIT_SHA_LEN}"

    # ... run
    run git_info_str
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "repo:$GIT_REPO_URL sha1:$head_sha tag:$NEW_TAG branch:$NEW_BRANCH" ]]
}

@test "git_info_str defaults to '-no remote-' if no repo found" {
    # ... setup - working dir is non-git dir
    use_test_repo_copy
    git checkout -b $NEW_BRANCH &>/dev/null
    git tag -a "$NEW_TAG" -m 'bah'

    export_shas
    head_sha="${HEAD_SHA:0:$GIT_SHA_LEN}"

    git_repo() { echo ""; }

    # ... run
    run git_info_str
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "repo:-no remote- sha1:$head_sha tag:$NEW_TAG branch:$NEW_BRANCH" ]]

}

@test "git_info_str defaults to '-no tag-' if no tag found" {
    # ... setup - working dir is non-git dir
    use_test_repo_copy
    git checkout -b $NEW_BRANCH &>/dev/null
    git tag -a "$NEW_TAG" -m 'bah'

    export_shas
    head_sha="${HEAD_SHA:0:$GIT_SHA_LEN}"

    git_tag() { echo ""; }

    # ... run
    run git_info_str
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "repo:$GIT_REPO_URL sha1:$head_sha tag:-no tag- branch:$NEW_BRANCH" ]]

}

@test "git_info_str defaults to '-no branch-' if no branch found" {
    # ... setup - working dir is non-git dir
    use_test_repo_copy
    git checkout -b $NEW_BRANCH &>/dev/null
    git tag -a "$NEW_TAG" -m 'bah'

    export_shas
    sha="${HEAD_SHA:0:$GIT_SHA_LEN}"

    git_branch() { echo ""; }

    # ... run
    run git_info_str
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "repo:$GIT_REPO_URL sha1:$sha tag:$NEW_TAG branch:-no branch-" ]]

}

@test "git_info_str on detached HEAD, no tag, no branch" {
    # ... setup - working dir is non-git dir
    use_test_repo_copy
    git checkout -b $NEW_BRANCH &>/dev/null

    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    echo 'new commit 2' >>README.md
    git commit -am "another arbitrary change for test $BATS_TEST_NAME"

    export_shas
    git checkout $SECOND_SHA # should result in DETACHED_HEAD
    sha="${SECOND_SHA:0:$GIT_SHA_LEN}"

    # ... run
    run git_info_str
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "repo:$GIT_REPO_URL sha1:$sha tag:-no tag- branch:-no branch-" ]]

}

@test "git_info_str on detached HEAD of tag, no branch" {
    # ... setup - working dir is non-git dir
    use_test_repo_copy
    git checkout -b $NEW_BRANCH &>/dev/null

    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"

    git tag -a $NEW_TAG -m 'bah'

    git checkout $NEW_TAG # should result in DETACHED_HEAD

    export_shas
    sha="${HEAD_SHA:0:$GIT_SHA_LEN}"

    # ... run
    run git_info_str
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "repo:$GIT_REPO_URL sha1:$sha tag:$NEW_TAG branch:-no branch-" ]]

}

@test "git_info_str if sha is empty string" {
    # ... setup - working dir is non-git dir
    use_test_repo_copy
    git checkout -b $NEW_BRANCH &>/dev/null

    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"

    git_sha() { echo ""; }

    # ... run
    run git_info_str
    print_on_err

    # ... verify
    [[ $status -eq 1 ]]
    echo $output | grep -q 'requires a sha1 as second param'

}
