#!/usr/bin/env bats
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#

load git

@test "git_tag succeeds, but no output if not a git repo" {

    # ... setup - working dir is non-git dir
    mkdir -p $TMPDIR/foo ; cd $TMPDIR/foo

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "" ]]
}

@test "git_tag outputs annotated tag name at HEAD" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    git tag -a $NEW_TAG -m 'bah'

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == $NEW_TAG ]]
}

@test "git_tag outputs nothing if no tag on HEAD commit" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "" ]]
}

@test "git_tag with GIT_SORT=semver outputs nothing if no tag on HEAD commit" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"

    export GIT_SORT=semver

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "" ]]
}

@test "git_tag with GIT_SORT=taggerdate outputs nothing if no tag on HEAD commit" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"

    export GIT_SORT=taggerdate

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "" ]]
}

@test "git_tag outputs lightweight tag at HEAD" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    git tag $NEW_TAG

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == $NEW_TAG ]]
}

@test "git_tag defaults to reverse alphanumeric sort order when multiple lightweight" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    git tag "${NEW_TAG}-top"
    git tag "${NEW_TAG}-001"
    git tag "${NEW_TAG}-stetson"
    git tag "${NEW_TAG}-apple"
    git tag "${NEW_TAG}-fedora"

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == $NEW_TAG-top ]]
}

@test "git_tag defaults to reverse alphanumeric sort order when multiple annotated" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    git tag -a "${NEW_TAG}-top" -m 'bah'
    git tag -a "${NEW_TAG}-apple" -m 'bah'
    git tag -a "${NEW_TAG}-001" -m 'bah'
    git tag -a "${NEW_TAG}-stetson" -m 'bah'
    git tag -a "${NEW_TAG}-fedora" -m 'bah'

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == $NEW_TAG-top ]]
}

@test "git_tag default lexical sort considers annotated and lightweight #1" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    git tag -a "${NEW_TAG}-top" -m 'bah'
    git tag -a "${NEW_TAG}-apple" -m 'bah'
    git tag -a "${NEW_TAG}-001" -m 'bah'
    git tag "${NEW_TAG}-umbrella" # lexically highest, but not annotated
    git tag -a "${NEW_TAG}-fedora" -m 'bah'

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == $NEW_TAG-umbrella ]]
}

@test "git_tag default lexical sort considers annotated and lightweight #2" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    git tag -a "${NEW_TAG}-top" -m 'bah'
    git tag -a "${NEW_TAG}-apple" -m 'bah'
    git tag "${NEW_TAG}-toast"
    git tag "${NEW_TAG}-tool"
    git tag -a "${NEW_TAG}-fedora" -m 'bah'

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == $NEW_TAG-top ]]
}

@test "git_tag semver sort - all tags are annotated" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"

    for tag in 10.0.2 12.0.0 0.0.1 1.1.1 ; do git tag -a $tag -m 'bah' ; done
    export GIT_SORT=semver

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == 12.0.0 ]]
}

@test "git_tag semver sort - all tags are lightweight" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"

    for tag in 10.0.2 12.0.0 0.0.1 1.1.1 ; do git tag $tag ; done
    export GIT_SORT=semver

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == 12.0.0 ]]
}

@test "git_tag semver sort - same if lightweight or annotated #1" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"

    lightweight="10.0.2 12.0.0"
    annotated="0.0.1 1.1.1"

    for tag in $annotated ; do git tag -a $tag -m 'foo' ; done
    for tag in $lightweight ; do git tag $tag ; done
    export GIT_SORT=semver

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == 12.0.0 ]]
}

@test "git_tag semver sort - same if lightweight or annotated #2" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    annotated="10.0.2 12.0.0"
    lightweight="0.0.1 1.1.1"

    for tag in $annotated ; do git tag -a $tag -m 'foo' ; done
    for tag in $lightweight ; do git tag $tag ; done
    export GIT_SORT=semver

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == 12.0.0 ]]
}

@test "git_tag semver sort - same if non-semver annotated tag" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    annotated="10.0.2 12.0.0 alpha 100alpha.0.0"
    lightweight="0.0.1 1.1.1"

    for tag in $annotated ; do git tag -a $tag -m 'foo' ; done
    for tag in $lightweight ; do git tag $tag ; done
    export GIT_SORT=semver

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == 12.0.0 ]]
}

@test "git_tag semver sort - same if non-semver lightweight tag" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    annotated="10.0.2 12.0.0 "
    lightweight="0.0.1 1.1.1 alpha 100alpha.0.0"

    for tag in $annotated ; do git tag -a $tag -m 'foo' ; done
    for tag in $lightweight ; do git tag $tag ; done
    export GIT_SORT=semver

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == 12.0.0 ]]
}

@test "git_tag with GIT_SORT=taggerdate lexical sort if only lightweight tags" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    for tag in a c b ; do git tag $tag ; sleep 1.1 ; done

    export GIT_SORT=taggerdate

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "c" ]]
}

@test "git_tag with GIT_SORT=taggerdate annotated tags preferred" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"
    git tag a ; sleep 1.1 ; git tag -a b -m foo ; sleep 1.1 ; git tag c

    export GIT_SORT=taggerdate

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "b" ]]
}

@test "git_tag with GIT_SORT=taggerdate using annotated tags" {
    # ... setup
    use_test_repo_copy
    echo 'new commit' >>README.md
    git commit -am "arbitrary change for test $BATS_TEST_NAME"

    for tag in 10.0.2 12.0.0 11.0.1 ; do git tag -a $tag -m 'foo'; sleep 1.1 ; done
    export GIT_SORT=taggerdate

    # ... run
    run git_tag
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output == "11.0.1" ]]
}

