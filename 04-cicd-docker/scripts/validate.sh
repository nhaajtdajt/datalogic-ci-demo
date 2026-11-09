#!/usr/bin/env bash

if ! command -v make >/dev/null 2>&1; then
    printf 'ERROR: GNU Make is required. Install make and try again.\n' >&2
    exit 1
fi

if ! repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"; then
    printf 'ERROR: Cannot find the repository directory.\n' >&2
    exit 1
fi

# shortcut: check the three available modules; extend this list when the remaining modules are supplied.
readmes=(
    "02-makefile-build/README.md"
    "03-pthreads/README.md"
    "04-cicd-docker/README.md"
)

status=0

for readme in "${readmes[@]}"; do
    if [[ -f "$repo_root/$readme" ]]; then
        printf 'OK: %s\n' "$readme"
    else
        printf 'ERROR: Missing file: %s\n' "$readme" >&2
        status=1
    fi
done

exit "$status"
