#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    printf 'Usage: bash %s RUN_DIRECTORY\n' "$0" >&2
    exit 2
fi

if ! run_dir="$(cd -- "$1" && pwd)"; then
    printf 'ERROR: The run directory does not exist.\n' >&2
    exit 1
fi

artifact="$run_dir/artifacts/sensor-demo"
expected_file="$run_dir/expected-output.txt"
result_file="$run_dir/test-result.txt"
normalized_file="$run_dir/normalized-result.txt"

if [[ ! -x "$artifact" ]]; then
    printf 'ERROR: Missing executable artifact: %s\n' "$artifact" >&2
    exit 1
fi

printf '%s\n' 'Embedded Linux training: 25 C' >"$expected_file"

if ! "$artifact" >"$result_file"; then
    printf 'ERROR: sensor-demo exited with a failure.\n' >&2
    exit 1
fi

# C programs use CRLF on Windows; normalize only the line ending for comparison.
sed 's/\r$//' "$result_file" >"$normalized_file"

if ! cmp -s -- "$expected_file" "$normalized_file"; then
    printf 'ERROR: Program output does not match the expected output.\n' >&2
    printf 'Expected: Embedded Linux training: 25 C\n' >&2
    printf 'Actual: '
    cat -- "$result_file"
    exit 1
fi

printf 'Test passed: %s\n' "$result_file"
