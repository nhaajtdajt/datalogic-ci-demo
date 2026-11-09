# C Programming with POSIX Threads

## Goal

Practice C programming for concurrent Embedded Linux applications using POSIX
threads (`pthreads`). Start from the scaffold in `src/threading_practice.c` and
implement each stage yourself. The starter intentionally has TODOs and is not a
completed program or build configuration.

## Learning Topics

| Topic | What you should be able to explain |
| --- | --- |
| Processes and threads | Threads share a process address space and resources, but have independent stacks and execution state. |
| POSIX thread API | `pthread_create`, `pthread_join`, thread functions, arguments, and return values. |
| Lifetime and ownership | A thread argument must remain valid until the worker has finished using it. |
| Shared state | Concurrent access to shared mutable data needs a synchronization design. |
| Data races | Unsynchronized conflicting accesses are undefined behavior in C; observed output is not guaranteed. |
| Mutexes | A mutex provides mutual exclusion around a shared invariant; every lock needs a clear unlock path. |
| Condition variables | Wait for a predicate while holding its mutex; signal/broadcast after changing the predicate. |
| Deadlocks | Lock ordering, holding locks while waiting, and forgotten unlocks can prevent progress. |
| Error handling | Pthread APIs normally return an error number directly; they do not report errors through `errno`. |
| Embedded design | Bounded work, predictable shutdown, resource limits, and choosing threads only when they help. |

## Setup

Install a C compiler and POSIX threads development support for your Linux host.
Record compiler and operating-system versions. Compile the exercise manually;
there is no Makefile in this module. Link with the compiler's pthread option,
commonly `-pthread`, and keep generated files in a local ignored build folder.

The starter uses fixed-size arrays to keep the first exercises focused. Do not
add detached threads: the assignment requires joining every created thread.

## Assignment

### 1. Complete Thread Creation and Joining

Implement the TODOs in `src/threading_practice.c`:

- Give each worker a distinct identifier through its argument structure.
- Create a fixed number of workers and print one clear message per worker.
- Join every successfully created thread before returning from `main`.
- Check each pthread function's return code and report errors with
  `strerror(return_code)`; do not assume `errno` contains that error.
- Ensure each argument remains valid until its corresponding thread has been
  joined.

Compile with warnings enabled. Run the program repeatedly and confirm all
workers finish. Do not require output to arrive in creation order: thread
scheduling makes interleaving nondeterministic.

### 2. Return Results and Partition Work

Extend the worker argument with a small range of integer work. Assign each
thread a disjoint range, calculate a partial sum in that thread, and return the
result using a well-defined lifetime strategy. Join threads and aggregate the
partial results in `main`.

Compare the result with a single-threaded calculation. Explain why disjoint
per-thread results can avoid a mutex, and why returning the address of a worker's
stack local would be invalid after the worker returns.

### 3. Reproduce and Fix a Data Race

Add a shared counter and let every worker increment it many times.
First run the intentionally unsynchronized version to discuss the bug, then
protect the update with a `pthread_mutex_t` and verify the deterministic result.
Do not treat one apparently correct run of the unsynchronized program as proof
that it is safe: the data race is undefined behavior and may produce different
results across runs or compilers.

Use a single cleanup path to destroy an initialized mutex after all workers
have joined. Explain the protected invariant and make sure no code path unlocks a
mutex it does not own.

### 4. Build a Bounded Producer/Consumer Queue

As an extension, create a fixed-size queue shared by one producer and one or
more consumers. Protect queue indices and state with a mutex and use condition
variables to wait while the queue is empty or full.

- Wait in a `while` loop that checks the condition predicate, not an `if`.
- Change queue state while holding the mutex, then signal or broadcast as needed.
- Define a shutdown marker/state so consumers can exit and be joined cleanly.
- Handle spurious wakeups and do not busy-wait.
- Document which thread owns each queue operation and when it is safe to destroy
  synchronization objects.

Do not hold the queue mutex while doing slow work unrelated to queue state.

### 5. Exercise Shutdown and Error Paths

Review partial thread-creation failure: join every thread that was created
successfully, release initialized resources exactly once, and return a failure
status. Keep cleanup understandable; avoid calling `pthread_join` on an
uninitialized thread identifier.

Describe how a signal-driven shutdown could be requested safely in an embedded
service. Do not call non-async-signal-safe pthread or stdio functions directly
from a signal handler; a full signal-handling implementation is optional.

### 6. Run Concurrency Checks

Use ThreadSanitizer if supported by your compiler, or another approved race
checker. Run it against the intentionally racy version, then against the
mutex-protected version. Record the tool/version, command, and result. If the
host cannot run the sanitizer, document that limitation and still explain the
race and synchronization reasoning.

Also test with one worker and several workers, and repeat the normal run. Do
not add timing sleeps to make a race appear or disappear; sleeps are not
synchronization.

### 7. Embedded-System Discussion

Write a short design note comparing this thread-based approach with a single
thread/event loop for a sensor-monitoring service. Address shared state, latency,
stack/memory cost per thread, priority inversion, shutdown, and what should be
measured before adding threads. No real hardware is required.

## Acceptance Criteria

- [ ] Starter TODOs are implemented and compiler warnings are addressed.
- [ ] All successfully created threads are joined; argument/result lifetimes are valid.
- [ ] Worker errors use pthread return codes correctly.
- [ ] A shared-counter race is explained and fixed with a mutex.
- [ ] Mutex and condition-variable state invariants are documented.
- [ ] Queue consumers shut down and join without busy-waiting (extension).
- [ ] Concurrency check results or host limitations are recorded.
- [ ] `REPORT.md` includes commands, observations, and the embedded design note.
- [ ] Generated binaries and reports/logs are not committed unless the mentor requests the report.

## References

- [Linux pthreads manual pages](https://man7.org/linux/man-pages/man7/pthreads.7.html)
- [POSIX threads overview](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/pthread.h.html)
- [GCC instrumentation options](https://gcc.gnu.org/onlinedocs/gcc/Instrumentation-Options.html)
