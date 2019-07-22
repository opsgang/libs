#!/usr/bin/env bats
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#
print_on_err() {
    echo "START OUTPUT--|$output|--END OUTPUT"
    echo "status: $status"
}

setup() {
    . habitual/std.functions || return 1

    export TMPDIR=$BATS_TMPDIR/$BATS_TEST_NAME
    mkdir -p $TMPDIR || true

    export FIXTURES="t/habitual/fixtures"
    export SL_TMPL="$FIXTURES/singleline.tmpl"
    export ML_TMPL="$FIXTURES/multiline.tmpl"
    export EXPECTED_ML_RESULT="$FIXTURES/multiline.result"
}

teardown() {
    rm -rf $BATS_TMPDIR/$BATS_TEST_NAME || true
}

@test "std::render_tmpl fails if path to tmpl not passed" {

    # ... run
    run std::render_tmpl
    print_on_err

    # ... verify
    [[ $status -ne 0 ]]
    echo "$output" | grep -q 'expects either /path/to/file as arg or as env var'
}

@test "std::render_tmpl with a single line template, all vars with vals" {
    # ... setup
    number=2 fruit=apple

    # ... run
    run std::render_tmpl $SL_TMPL
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    echo "$output" | grep -q '^I eat 2 apples.$'
}

@test "std::render_tmpl with a single line template, all vars no vals" {
    # ... run
    run std::render_tmpl $SL_TMPL
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    echo "$output" | grep -q '^I eat  s.$'
}

@test "std::render_tmpl with a single line template, file_tmpl env var set" {
    # ... setup
    number=2 fruit=apple file_tmpl=$SL_TMPL

    # ... run
    run std::render_tmpl
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    echo "$output" | grep -q '^I eat 2 apples.$'
}

@test "std::render_tmpl prefers arg to file_tmpl env_var" {
    # ... setup
    number=2 fruit=apple file_tmpl=/path/does/not/exist

    # ... run
    run std::render_tmpl $SL_TMPL
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    echo "$output" | grep -q '^I eat 2 apples.$'
}

@test "std::render_tmpl fails if tmpl file unreadable" {
    # ... setup
    f=$(mktemp)
    cp $SL_TMPL $f
    chmod 0333 $f

    # ... run
    run std::render_tmpl $f
    print_on_err

    # ... verify
    [[ $status -ne 0 ]]
    echo "$output" | grep -q "$f is not readable"
}

@test "std::render_tmpl renders simple multiline tmpl" {
    # ... setup
    outfile=$(mktemp)
    local file_tmpl="$ML_TMPL" prenombre="Foo" apellido="Bar"

    # ... run
    std::render_tmpl > $outfile
    status=$?

    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    diff $outfile $EXPECTED_ML_RESULT
}

@test "std::render_tmpl renders tmpl as empty str" {
    # ... setup
    infile=$(mktemp) ; outfile=$(mktemp)
    echo '$not_defined'>$infile

    # ... run
    std::render_tmpl $infile > $outfile
    status=$?

    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    diff $outfile <(echo "")
}

@test "std::render_tmpl multiline tmpl with some undefined vars" {
    # ... setup
    file_tmpl=$ML_TMPL apellido="Bar"
    outfile=$(mktemp)

    # ... run
    std::render_tmpl > $outfile
    status=$?

    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    diff $outfile $FIXTURES/var_not_defined.result
}

@test "std::render_tmpl backslashed vars should not be interpolated during render" {
    # ... setup
    file_tmpl="$FIXTURES/escaped_vars.tmpl"
    var="\$var is escaped in tmpl so not interpolated"
    outfile=$(mktemp)

    # ... run
    std::render_tmpl > $outfile
    status=$?

    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    diff $outfile $FIXTURES/escaped_vars.result
}

@test "std::render_tmpl shell code in tmpl not executed by default" {
    # ... setup
    file_tmpl="$FIXTURES/breakout.tmpl"
    outfile=$(mktemp)

    # ... run
    std::render_tmpl > $outfile
    status=$?

    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    diff $outfile $FIXTURES/breakout_not_allowed.result
}

@test "std::render_tmpl shell code in tmpl executed if allow_code is set" {
    # ... setup
    file_tmpl="$FIXTURES/breakout.tmpl"
    allow_code=true
    outfile=$(mktemp)

    # ... run
    std::render_tmpl > $outfile
    status=$?

    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    diff $outfile $FIXTURES/breakout_allowed.result
}

@test "std::render_tmpl shell code in tmpl escaped if not already escaped" {
    # ... setup
    file_tmpl="$FIXTURES/some_backslashed_breakouts.tmpl"
    outfile=$(mktemp)

    # ... run
    std::render_tmpl > $outfile
    status=$?

    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    diff $outfile $FIXTURES/some_backslashed_breakouts.result
}

@test "std::render_tmpl stops multiple backslashes to force shell code execution" {
    # ... setup
    file_tmpl="$FIXTURES/multiple_backslashes_for_breakouts.tmpl"
    outfile=$(mktemp)

    # ... run
    std::render_tmpl > $outfile
    status=$?

    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    diff $outfile $FIXTURES/some_backslashed_breakouts.result
}
