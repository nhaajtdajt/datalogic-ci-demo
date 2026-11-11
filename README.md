# DataLogic CI/CD Practice

This repository contains the Makefile, pthreads, and local CI/CD exercises.

The Jenkins pipeline has three stages:

1. `Validate` checks the available module README files and required tools.
2. `Build` cleans and builds `sensor-demo`, then publishes the current executable into a run-specific artifact directory.
3. `Test` runs that artifact and compares its exact output with `Embedded Linux training: 25 C`.

Jenkins on Windows uses MSYS2 Bash at `C:\msys64\usr\bin\bash.exe`. The `Jenkinsfile` polls the source repository every two minutes and starts a build when it detects a new commit.

To run the same checks manually from MSYS2 Bash:

```bash
export PATH=/ucrt64/bin:/usr/bin:$PATH
bash 04-cicd-docker/scripts/validate.sh
run_dir="$(mktemp -d "$PWD/04-cicd-docker/runs/manual.XXXXXX")"
bash 04-cicd-docker/scripts/build.sh "$run_dir"
bash 04-cicd-docker/scripts/test.sh "$run_dir"
```
