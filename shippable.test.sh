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

main() {
    mkdir -p $CIUSER_RESULTS_DIR || return 1
    echo "INFO: will store test results in $CIUSER_RESULTS_DIR"

    echo "INFO: running tests for bash libs"
    ( cd $BASH_LIBS_DIR && run_bash_tests )
}

main
