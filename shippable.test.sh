#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
CIUSER_RESULTS_DIR="${CIUSER_RESULTS_DIR:-/home/ciuser/shippable/testresults}"
CONCURRENT_TESTS="${CONCURRENT_TESTS:-4}"
BASH_LIBS_DIR="${BASH_LIBS_DIR:-/home/ciuser/build/bash}"
TEST_ROOT="${TEST_ROOT:-bats}" # path to file or dir containing bats tests

run_bash_tests() {
    local rc=0

    # ... run bats tests for console log
    (
        set -o pipefail
        bats -r -t -j $CONCURRENT_TESTS bats \
        | tee bats.tap
    )
    rc=$?

    # ... bats output => junit-compatible xml
    # We are using node tap-xunit module because it parses
    # test run STDOUT/STDERR better than the tap-junit module.
    cat bats.tap \
    | awk -f bats/bats_tap12_to_tap13.awk \
    | strip-ansi \
    | tap-xunit > $CIUSER_RESULTS_DIR/bash_test_results.xml

    rm bats.tap

    return $rc
}

create_tmpl_repo() {
    local tmpl_repo="/var/tmp/opsgang/libs/repo"
    local src_repo_url="https://github.com/opsgang/libs"

    [[ -d $tmpl_repo ]] && rm -rf $tmpl_repo
    mkdir -p $(dirname $tmpl_repo)
    git clone --depth 5 --branch master $src_repo_url $tmpl_repo &>/dev/null

    (cd $tmpl_repo && git reset --hard >/dev/null)

    return 0
}

main() {
    mkdir -p $CIUSER_RESULTS_DIR || return 1
    echo "INFO: will store test results in $CIUSER_RESULTS_DIR"

    echo "INFO: creating template repo for habitual/git.functions tests"
    create_tmpl_repo ; ls -ld /var/tmp/opsgang/libs/repo

    echo "INFO: running tests for bash libs"
    ( cd $BASH_LIBS_DIR && run_bash_tests )
}

main
