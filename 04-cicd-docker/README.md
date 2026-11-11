# CI/CD Fundamentals, Shell Scripting, and Docker

## Goal
//test

Simulate a CI pipeline locally using shell scripts, then run it in a reproducible Docker environment. Remote CI/CD access is not required. You must implement the scripts, Dockerfile, and stage orchestration yourself; no ready-made pipeline is provided. GitLab CI is an optional extension when permissions are available.

## Learning Topics

| Topic | Explanation to learn |
| --- | --- |
| CI/CD purpose | Automated checks catch integration failures and make delivery repeatable. |
| Continuous Integration | Changes are regularly integrated and automatically built/tested. |
| Continuous Delivery | Verified output is ready for release, possibly with manual approval. |
| Continuous Deployment | Qualifying changes are released automatically without a manual release gate. |
| Pipeline, stages, jobs, runners | Pipelines organize jobs into ordered stages; runners execute them. Your local script/process simulates these roles. |
| YAML | Mappings, sequences, indentation, and quoting describe hosted pipeline configuration. Shell scripts implement the local exercise instead. |
| Build and test | Compilation success and correct runtime behavior are separate checks. |
| Artifacts and reports | Preserve useful outputs and report stage outcomes; plain logs are not structured test reports. |
| Triggers and conditions | Pushes, merge requests, schedules, and manual actions can trigger CI; rules select work. Locally, arguments simulate events. |
| Shell scripting | Shebangs, variables, quoting, arguments, functions, conditionals, loops, exit codes, redirection, and traps. |
| Docker | Images are templates; containers are instances; Dockerfiles define environments; registries distribute images. |
| Mounts and reproducibility | Bind mounts expose source/output; pinned image versions help keep environments consistent. |

## Prerequisites

- Linux shell with Bash, Git, and common command-line tools.
- GCC and GNU Make for build integration, installed by the intern.
- Docker Engine or an approved compatible runtime for the container exercise.
- Completed [Makefile assignment](../02-makefile-build/README.md) for the final build/test stages. Start with shell validation while that work is pending.

Record tool versions. Docker access can grant host-level privileges; use an approved setup, never enable privileged mode or change host permissions just to bypass an error. If Docker is unavailable, finish the local pipeline and document the unverified container requirement for the mentor.

## Files You Must Create

Inside this folder, implement:

```text
scripts/
  pipeline.sh
  validate.sh
  build.sh
  test.sh
Dockerfile
REPORT.md
```

## Assignment

### 1. Practice Shell Fundamentals

Before writing the orchestrator, create `scripts/validate.sh`. It must check that all five module README files exist, print clear diagnostics, and return zero on success and nonzero if any file is missing.

Requirements:

- Use a Bash shebang and consistent execution permissions.
- Resolve paths from the script location rather than assuming the caller's current directory. Support repository paths containing spaces.
- Use quoted variables and a loop for repeated checks.
- Send errors to standard error and normal progress to standard output.
- Add a prerequisite check using `command -v` and a helpful failure message.
- Explain exit codes and how the caller observes a failure.

Check syntax with `bash -n`. Use ShellCheck if available and explain any fixes. Test success and a missing-file failure in a disposable copy; do not delete a teammate's tracked work. Never hide errors with `|| true`.

### 2. Implement an Ordered Local Pipeline

Write `scripts/pipeline.sh` to invoke validation, build, and test in that order. Each stage has its own script and explicit status. Build must use the Makefile module's interface, not duplicate its compiler commands. Test must consume the executable produced by the current run and compare its exact output with:

```text
Embedded Linux training: 25 C
```

For the first version, run stages sequentially on the local host. Before build, remove stale generated build output using the project's clean target. Copy the new executable into the current run's artifact directory and have test consume that copy. Do not accept an old executable left over from a previous run.

The orchestrator must:

- Fail immediately if validation, build, or test fails; skip dependent stages.
- Return a nonzero pipeline exit code when a stage fails.
- Record start/end times, stage status, and the source Git commit identifier.
- Create a distinct run directory containing stage logs and artifacts.
- Preserve logs and write a final summary even when a stage fails.
- Clean only temporary files it owns; investigate an `EXIT` trap for reporting.

Be careful with `command | tee`: a successful logger can hide the command's failure. Use Bash's `pipefail` and deliberate exit-code handling. `set -e` alone is not a complete failure-handling strategy; explain how your implementation handles failures inside conditionals, functions, and logging pipelines.

### 3. Add Local Trigger and Condition Simulation

Define and document this command interface, invoked from the repository root:

```sh
bash 04-cicd-docker/scripts/pipeline.sh --event push --branch feature/example
bash 04-cicd-docker/scripts/pipeline.sh --event merge-request --branch feature/example
bash 04-cicd-docker/scripts/pipeline.sh --event manual --branch main
```

These are commands for your future implementation, not supplied runnable code. Validate arguments, support `--help`, and reject unknown events/options clearly. Run validation/build/test for all three supported events. Add a packaging step only when the event is `manual` and branch is `main`; otherwise mark it skipped. An archive of the current run's artifacts is enough: no deployment is required.

Explain how a real push-triggered pipeline differs: your script simulates event inputs and must be invoked manually; it does not watch the remote or run after every push automatically. An optional local Git hook may demonstrate automatic invocation, but hooks are local, not a replacement for server-side CI.

### 4. Publish Local Artifacts and Reports

Each run directory must contain stage logs, the executable if build succeeded, a test-result text file if test ran, and a machine-readable stage summary. Choose a simple tab-separated format with stage/status/exit-code fields, or use a proper JSON serializer if selecting JSON. Include skipped stages explicitly.

Retain failure logs even when no executable exists. Define a cleanup/retention policy so old runs do not fill the disk. Explain artifacts versus caches: artifacts represent run results; caches speed reusable inputs and must not be necessary for correctness. A plain text result is not JUnit XML.

### 5. Containerize the Environment

Write `Dockerfile` with a supported Linux base and the required shell, compiler, Make, Git, and utilities. Build it yourself and record its tag or digest and tool versions. A base digest does not also pin packages fetched during build.

Example command shapes to adapt after implementation:

```sh
docker build -t intern-ci:practice 04-cicd-docker
docker run --rm intern-ci:practice bash --version
docker run --rm --user "$(id -u):$(id -g)" \
  -v "$PWD:/workspace" -w /workspace intern-ci:practice \
  bash 04-cicd-docker/scripts/pipeline.sh --event push --branch feature/example
```

Run from the repository root. Ensure mounted output stays writable and remains after container deletion. Compare host and container results. A fresh container must need no manual package installation. Do not bake secrets into the image or use Docker-in-Docker for this exercise.

### 6. Prove Failure Handling

In a disposable checkout or controlled practice branch, demonstrate:

| Case | Expected result |
| --- | --- |
| Correct input | Validation, build, test succeed; artifact and summary exist. |
| Missing README | Validation fails; build/test skipped; pipeline fails. |
| C syntax error | Build fails; test skipped; compiler log retained. |
| Sensor returns 26 | Build succeeds; exact-output test fails; pipeline fails. |
| Unknown event | Argument error; no build/test runs. |
| Feature push | Checks run; packaging skipped. |
| Manual event on main | Checks pass, then current-run artifacts are packaged. |
| Different caller directory or path with spaces | Path handling remains correct. |

Restore intentional changes afterward. Report expected and actual exit codes, not merely screenshots of successful output.

## Optional: GitLab CI Translation

Only when an approved remote and runner are available, write a root `.gitlab-ci.yml` that invokes your existing stage scripts. Learn YAML using GitLab CI Lint. Add build/test stages, preserve artifacts with expiry, and use `rules`/`workflow:rules` for pushes and merge requests without duplicate pipelines.

Hosted jobs have isolated workspaces: transfer the executable through GitLab artifacts and explicit dependencies, not assumptions about previous local files. Map your local run-output contract to each job's workspace deliberately.

For Docker/Kubernetes runners, publish the image to an accessible approved registry; shell runners do not use `image:` and need host tools installed.

This extension is not part of mandatory acceptance and requires no production deployment or remote administrative changes.

## Acceptance Criteria

- [ ] Scripts are intern-written, syntax-checked, and have documented interfaces.
- [ ] Local validation/build/test run in order with correct exit-code propagation.
- [ ] Failure cases stop dependent work and retain logs and final summaries.
- [ ] Fresh per-run artifacts prevent stale-output false positives.
- [ ] Event/branch arguments demonstrate conditions and skipped packaging.
- [ ] Container environment runs the same pipeline without manual modification.
- [ ] `REPORT.md` records successful/failing runs, versions, and CI concept mapping.
- [ ] No remote CI permissions or committed generated output are required.

## References

- [Bash manual](https://www.gnu.org/software/bash/manual/)
- [ShellCheck](https://www.shellcheck.net/)
- [GitLab CI/CD](https://docs.gitlab.com/ci/)
- [GitLab YAML reference](https://docs.gitlab.com/ci/yaml/)
- [Docker build concepts](https://docs.docker.com/build/concepts/)
