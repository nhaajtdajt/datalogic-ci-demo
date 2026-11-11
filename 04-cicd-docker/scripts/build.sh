#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    printf 'Usage: bash %s RUN_DIRECTORY\n' "$0" >&2
    exit 2
fi

if ! run_dir="$(cd -- "$1" && pwd)"; then
    printf 'ERROR: The run directory must already exist.\n' >&2
    exit 1
fi

if ! repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"; then
    printf 'ERROR: Cannot find the repository directory.\n' >&2
    exit 1
fi

module_dir="$repo_root/02-makefile-build"
artifact_dir="$run_dir/artifacts"

# Refuse an existing artifact directory so a rerun cannot reuse an old executable.
mkdir -- "$artifact_dir" || exit "$?"

make -C "$module_dir" clean || exit "$?"
make -C "$module_dir" all || exit "$?"

if [[ ! -x "$module_dir/build/sensor-demo" ]]; then
    printf 'ERROR: Build did not produce an executable sensor-demo.\n' >&2
    exit 1
fi

cp -- "$module_dir/build/sensor-demo" "$artifact_dir/sensor-demo" || exit "$?"
printf 'Build artifact: %s\n' "$artifact_dir/sensor-demo"
