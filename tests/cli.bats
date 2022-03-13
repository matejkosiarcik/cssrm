#!/usr/bin/env bats
# shellcheck disable=SC2086

function setup() {
    cd "$BATS_TEST_DIRNAME/.."  || exit 1 # project root
    if [ -z "${COMMAND+x}" ]; then exit 1; fi
}

@test 'Get --help' {
    # when
    run $COMMAND --help

    # then
    [ "$status" -eq 0 ]
    printf '%s\n' "$output" | grep -- '--help'
    printf '%s\n' "$output" | grep -- '--version'
    printf '%s\n' "$output" | grep 'file'
    printf '%s\n' "$output" | grep -- '--output'
}

@test 'Verify --help and -h equals' {
    # when
    run $COMMAND -h
    short="$output"
    run $COMMAND --help
    long="$output"

    # then
    [ "$short" = "$long" ]
}

@test 'Get --version' {
    # when
    run $COMMAND --version

    # then
    [ "$status" -eq 0 ]
    printf '%s\n' "$output" | grep 'css-mini-mini-mini'
    printf '%s\n' "$output" | grep -v '0.0.0'
    printf '%s\n' "$output" | grep -v 'N/A'
    printf '%s\n' "$output" | grep -E 'v[0-9]+\.[0-9]+\.[0-9]+'

    cli_version="$(printf '%s\n' "$output" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sed -E 's~[a-zA-Z]~~g')"
    package_version="$(jq .version 'package.json' | sed -E 's~"~~g')"
    [ "$cli_version" = "$package_version" ]
}

@test 'Verify --version and -V equals' {
    # when
    run $COMMAND -V
    short="$output"
    run $COMMAND --version
    long="$output"

    # then
    [ "$short" = "$long" ]
}
