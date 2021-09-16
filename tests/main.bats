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

@test 'Standard input' {
    # given
    reference_input='data/style.css'

    # when
    run $COMMAND -o "$tmpdir/out.txt" <"${reference_input}"

    # then
    [ "$status" -eq 0 ]
    [ "$(wc -c <"$tmpdir/out.txt")" -gt 0 ]
    [ "$(wc -c <"$tmpdir/out.txt")" -lt "$(wc -c <"$reference_input")" ]
}

@test 'Standard output' {
    # given
    reference_input='data/style.css'

    # when
    $COMMAND "${reference_input}" >"$tmpdir/out.txt"

    # then
    [ "$(wc -c <"$tmpdir/out.txt")" -gt 0 ]
    [ "$(wc -c <"$tmpdir/out.txt")" -lt "$(wc -c <"$reference_input")" ]
}

@test 'Long argument' {
    # given
    reference_input='data/style.css'

    # when
    run $COMMAND "${reference_input}" --output "$tmpdir/out.txt"

    # then
    [ "$status" -eq 0 ]
    [ "$(wc -c <"$tmpdir/out.txt")" -gt 0 ]
    [ "$(wc -c <"$tmpdir/out.txt")" -lt "$(wc -c <"$reference_input")" ]
}

@test 'Short argument' {
    # given
    reference_input='data/style.css'

    # when
    run $COMMAND "${reference_input}" -o "$tmpdir/out.txt"

    # then
    [ "$status" -eq 0 ]
    [ "$(wc -c <"$tmpdir/out.txt")" -gt 0 ]
    [ "$(wc -c <"$tmpdir/out.txt")" -lt "$(wc -c <"$reference_input")" ]
}
