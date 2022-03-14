#!/usr/bin/env bats
# shellcheck disable=SC2086

function setup() {
    cd "$BATS_TEST_DIRNAME/.." || exit 1 # project root
    if [ -z "${COMMAND+x}" ]; then exit 1; fi
    tmpdir="$(mktemp -d)"
    export tmpdir
}

function teardown() {
    rm -rf "$tmpdir"
}

@test 'Non existent file' {
    # when
    run $COMMAND "$tmpdir/style.css"

    # then
    [ "$status" -ne 0 ]
}

@test 'Error - when missing file argument' {
    # when
    run $COMMAND

    # then
    [ "$status" -ne 0 ]
}

@test 'Error - when the file does not exist' {
    # when
    run $COMMAND "$tmpdir/style.css"

    # then
    [ "$status" -ne 0 ]
}

@test 'Error - when a file does not exist' {
    # given
    cp 'data/style.css' "$tmpdir/style1.css"

    # when
    run $COMMAND "$tmpdir/style1.css" "$tmpdir/style2.css"

    # then
    [ "$status" -ne 0 ]
}

@test 'Optimize single file' {
    # given
    cp 'data/style.css' "$tmpdir/style.css"

    # when
    run $COMMAND "$tmpdir/style.css"

    # then
    [ "$status" -eq 0 ]
    [ "$(wc -c <"$tmpdir/style.css")" -gt 0 ]
    [ "$(wc -c <"$tmpdir/style.css")" -lt "$(wc -c <'data/style.css')" ]
}

@test 'Optimize multiple files' {
    # given
    cp 'data/style.css' "$tmpdir/style1.css"
    cp 'data/style.css' "$tmpdir/style2.css"
    cp 'data/style.css' "$tmpdir/style3.css"

    # when
    run $COMMAND "$tmpdir/style1.css" "$tmpdir/style2.css"

    # then
    [ "$status" -eq 0 ]
    [ "$(wc -c <"$tmpdir/style1.css")" -gt 0 ]
    [ "$(wc -c <"$tmpdir/style1.css")" -lt "$(wc -c <'data/style.css')" ]
    [ "$(wc -c <"$tmpdir/style2.css")" -gt 0 ]
    [ "$(wc -c <"$tmpdir/style2.css")" -lt "$(wc -c <'data/style.css')" ]
    [ "$(wc -c <"$tmpdir/style3.css")" -eq "$(wc -c <'data/style.css')" ]
}

@test 'Optimize directory' {
    # given
    cp 'data/style.css' "$tmpdir/style1.css"
    cp 'data/style.css' "$tmpdir/style2.css"

    # when
    run $COMMAND "$tmpdir"

    # then
    [ "$status" -eq 0 ]
    [ "$(wc -c <"$tmpdir/style1.css")" -gt 0 ]
    [ "$(wc -c <"$tmpdir/style1.css")" -lt "$(wc -c <'data/style.css')" ]
    [ "$(wc -c <"$tmpdir/style2.css")" -gt 0 ]
    [ "$(wc -c <"$tmpdir/style2.css")" -lt "$(wc -c <'data/style.css')" ]
}

@test 'Optimize directory (recursively)' {
    # given
    cp 'data/style.css' "$tmpdir/style1.css"
    mkdir -p "$tmpdir/nested"
    cp 'data/style.css' "$tmpdir/nested/style2.css"

    # when
    run $COMMAND "$tmpdir"

    # then
    [ "$status" -eq 0 ]
    [ "$(wc -c <"$tmpdir/style1.css")" -gt 0 ]
    [ "$(wc -c <"$tmpdir/style1.css")" -lt "$(wc -c <'data/style.css')" ]
    [ "$(wc -c <"$tmpdir/nested/style2.css")" -gt 0 ]
    [ "$(wc -c <"$tmpdir/nested/style2.css")" -lt "$(wc -c <'data/style.css')" ]
}
