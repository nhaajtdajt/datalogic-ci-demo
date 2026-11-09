# Makefile and Build Process

## Goal and Starter Files

Implement your own Makefile for a small multi-file C project. The existing
Makefile is intentionally a TODO scaffold, not a build solution.
[main.c](src/main.c) prints the value from [sensor.c](src/sensor.c),
whose function is declared in [sensor.h](include/sensor.h).

Your executable must be `build/sensor-demo` with exact output:

```text
Embedded Linux training: 25 C
```

## Learning Topics

| Topic | Explanation to learn |
| --- | --- |
| Build system | Defines how inputs become outputs and when work must be repeated. |
| Compilation vs. linking | Compile each translation unit to an object; link objects/libraries into an executable. |
| Source, object, executable | `.c` is source; `.o` is relocatable machine code; the executable is runnable output. |
| GCC process | Preprocessing, compilation, assembly, linking; explore `-E`, `-S`, and `-c`. |
| Makefile syntax | A target has prerequisites and a recipe; recipe lines normally start with a literal tab. |
| Dependencies | Missing/newer prerequisites cause rebuilding; header changes must be tracked. |
| Variables | Separate compiler, preprocessor flags, compiler flags, linker flags, and libraries. |
| Automatic variables and patterns | `$@` is target, `$<` first prerequisite, `$^` all prerequisites; pattern rules avoid duplicated recipes. |
| Incremental builds and clean | Rebuild affected outputs only; remove generated files without deleting source. |

## Setup

Install GCC and GNU Make yourself and record their versions. Configure your
editor to preserve recipe tabs. Root access is not needed for build or staged
installation. Keep all generated output ignored in Git.

## Assignment

### 1. Explore GCC Manually

Compile both sources into separate objects under `build/`, providing the header
search path explicitly. Link the objects and run the executable. Inspect
preprocessed and assembly output for one source using GCC phase options.

Intentionally omit the include path, then omit the sensor object at link time.
Record both errors and distinguish compile failure from link failure. Fix the
commands before writing the Makefile.

### 2. Implement Rules

Your Makefile must:

- Make default `all` build `build/sensor-demo`.
- Compile sources separately and link through a distinct rule.
- Use overrideable `CC`, `CPPFLAGS`, `CFLAGS`, `LDFLAGS`, and `LDLIBS` correctly.
- Enable useful compiler warnings.
- Use a pattern rule and automatic variables for object compilation.
- Create build directories safely even under `make -j2`.
- Track headers using generated dependencies (`-MMD -MP` and included `.d`
  files) or equally correct explicit prerequisites for this sample.
- Implement `test` to check exact output and fail on a mismatch.
- Implement idempotent `clean` that removes generated build files only.
- Implement `install` depending on the executable, honoring `PREFIX`/`DESTDIR`.
- Mark action targets `all`, `test`, `clean`, and `install` as `.PHONY`.

Investigate order-only prerequisites for directories. Keep link libraries after
object inputs. Do not put a complete compile-and-link command into every target.

### 3. Verify Dependency-Based Rebuilds

| Experiment | Expected behavior |
| --- | --- |
| First clean build | Both sources compile and the executable links. |
| Immediate second `make` | No compile or link command runs. |
| Touch `src/sensor.c` | Sensor object recompiles; executable relinks. |
| Touch `include/sensor.h` | Both objects recompile because both include it; executable relinks. |
| Delete executable only | Existing objects reused; linking runs. |
| `make clean` twice | Both succeed; sources remain intact. |
| Clean parallel build, `make -j2` | No directory race or missing prerequisite. |

Record actual commands executed. Use `make -n` to inspect planned work without
running it. Explain why changing compiler flags alone is not automatically
detected by ordinary timestamp-based Make rules and when a clean build is needed.

### 4. Verify Installation Without Root

From this module, use your implemented target with:

```bash
make install DESTDIR="$PWD/staging" PREFIX=/usr
```

Expect executable `staging/usr/bin/sensor-demo` and the same runtime output.
Explain `PREFIX` as the eventual installation location and `DESTDIR` as a
prepended packaging/staging root. Do not use `sudo` or install to the real host
filesystem for the exercise.

## Acceptance Criteria

- Manual GCC phases and compile/link errors are explained.
- `all`, `test`, `clean`, and `install` work from a fresh checkout.
- Separate objects, variables, pattern rules, and automatic variables exist.
- Incremental and parallel-build experiments match expected behavior.
- Installation honors `PREFIX`/`DESTDIR` without root.
- Output is ignored; `REPORT.md` records commands and CI handoff.

## References

- [GNU Make manual](https://www.gnu.org/software/make/manual/)
- [GCC overall options](https://gcc.gnu.org/onlinedocs/gcc/Overall-Options.html)
