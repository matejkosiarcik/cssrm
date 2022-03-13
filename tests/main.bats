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

@test 'Single file - Standard input' {
    # given
    reference_input='data/style.css'

    # when
    run $COMMAND -o "$tmpdir/out.txt" <"$reference_input"

    # then
    [ "$status" -eq 0 ]
    [ "$(wc -c <"$tmpdir/out.txt")" -gt 0 ]
    [ "$(wc -c <"$tmpdir/out.txt")" -lt "$(wc -c <"$reference_input")" ]
}

@test 'Single file - Standard output' {
    # given
    reference_input='data/style.css'

    # when
    $COMMAND "$reference_input" >"$tmpdir/out.txt"

    # then
    [ "$(wc -c <"$tmpdir/out.txt")" -gt 0 ]
    [ "$(wc -c <"$tmpdir/out.txt")" -lt "$(wc -c <"$reference_input")" ]
}

@test 'Single file - Short output argument' {
    # given
    reference_input='data/style.css'

    # when
    run $COMMAND "$reference_input" -o "$tmpdir/out.txt"

    # then
    [ "$status" -eq 0 ]
    [ "$(wc -c <"$tmpdir/out.txt")" -gt 0 ]
    [ "$(wc -c <"$tmpdir/out.txt")" -lt "$(wc -c <"$reference_input")" ]
}

@test 'Single file - Long output argument' {
    # given
    reference_input='data/style.css'

    # when
    run $COMMAND "$reference_input" --output "$tmpdir/out.txt"

    # then
    [ "$status" -eq 0 ]
    [ "$(wc -c <"$tmpdir/out.txt")" -gt 0 ]
    [ "$(wc -c <"$tmpdir/out.txt")" -lt "$(wc -c <"$reference_input")" ]
}

@test 'Single file - Overwrite input' {
    # given
    reference_input='data/style.css'
    file="$tmpdir/style.css"
    cp "$reference_input" "$file"

    # when
    run $COMMAND "$file" --overwrite

    # then
    [ "$status" -eq 0 ]
    [ "$(wc -c <"$file")" -gt 0 ]
    [ "$(wc -c <"$file")" -lt "$(wc -c <"$reference_input")" ]
}
