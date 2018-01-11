# vim: et sr sw=4 ts=4 smartindent syntax=sh:
FAILURES=""
SRC="${0##t/}"

run_t() {
    local func="$1"
    local pad=""
    local desc="$func"
    local t_func="t_$func"

    [[ ! -z "$SUITE" ]] && pad="    " && desc="[$SUITE] $func"
    if declare -f $t_func >/dev/null
    then
        echo "INFO $0:$pad running test for: $desc"
        ! $t_func && FAILURES="$FAILURES $t_func" && return 1
        return 0
    else
        echo "INFO $0: no tests for $func. Skipping"
    fi
}

funcs_to_test() {
    local src="$1"
    grep -Po '^(function +)?[\w_]+ *\(\) *{ *$' $src | sed -e 's/\([^ (]\+\).*/\1/'
}

source_src_and_deps() {
    local deps="$*"
    local rc=0 file=""
    for file in $SRC $*; do
        echo "INFO $0: sourcing $file"
        ! . $file && echo "ERROR $0: ... can't source $file" >&2 && rc=1
    done
    return $rc
}

run_all() {
    for func in $(funcs_to_test $SRC); do
        run_t $func
        unset SUITE
    done

    if [[ "$FAILURES" =~ ^[\ ]*$ ]]; then
        echo "INFO: ALL TESTS SUCCESSFUL"
        return 0
    else
        echo "ERROR: FAILURES: $FAILURES"
        return 1
    fi
}
