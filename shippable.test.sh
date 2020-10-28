#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
CIUSER_HOME=/home/ciuser
CIUSER_BUILD_DIR=$CIUSER_HOME/build
BASH_LIBS_DIR=$CIUSER_BUILD_DIR/bash

find_libs_to_test() {
    find . -path './t' -prune -o -name '*.functions' -print
}

run_bash_test_file() {
    local lib="$1"
    local f="t/${lib#./}"

    [[ ! -x $f ]] && echo "INFO: no tests for $lib in $f" && return 0

    echo -e "\n\nINFO: RUNNING $f as $CIUSER in $BASH_LIBS_DIR ..."
    su -c "cd $BASH_LIBS_DIR && $f" ciuser && return 0

    echo >&2 "ERROR: failure from $lib"
    return 1
}

run_bash_tests() {
    local rc=0
    for lib in $(find_libs_to_test); do
        run_bash_test_file "$lib" || rc=1
        shellcheck "$lib" || rc=1
    done
    return $rc
}

main() {
    echo "INFO: running tests for bash libs"
    ( cd $BASH_LIBS_DIR && run_bash_tests )
}

main
