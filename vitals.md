# Vital signs

Appended, never regenerated. One reading says nothing; a series says something.

## Part 1 — Measure leftovers (core + engine), 2026-09-13

| reading | value |
|---|---|
| tests, engine package | 37 in 5 suites |
| how long the tests take, tests alone | 0.001 s ("Test run with 37 tests in 5 suites passed after 0.001 seconds") |
| ten slowest tests | every test reports 0.001 s — the runner's resolution floor; no test stands out yet |
| ten pieces with the most branches | `MeasureLeftovers.refusal(for:)` 3; every other piece 1 |
| coverage, engine package | regions 100.00%, functions 100.00%, lines 100.00% (43 regions, 22 functions, 141 lines) |
| mutation tally beside it | 6 mutants by hand on `MeasureLeftovers`, 6 killed, 0 survived |

The mutants: threshold `>=`→`>`; equal-room order `<`→`>`; shut-down/running swapped;
open-and-pointed-at preferring the tools; device support named by the model instead of
the version; the announcement moved after the size read. Each judged by the engine
package's own suite, by exit code.

## Part 2 — Delete leftover (engine), 2026-09-13

| reading | value |
|---|---|
| tests, engine package | 49 in 6 suites |
| how long the tests take, tests alone | 0.002 s (was 0.001 s at part 1, over 37 tests) |
| ten slowest tests | still every test at 0.001–0.002 s; nothing stands out |
| ten pieces with the most branches | `DeleteLeftover.remove(_:)` 3, `MeasureLeftovers.refusal(for:)` 3; every other piece 1 |
| coverage, engine package | regions 100.00%, functions 100.00%, lines 100.00% (55 regions, 25 functions, 165 lines) |
| mutation tally beside it | 11 by hand so far on the engine, 11 killed, 0 survived (5 new on `DeleteLeftover`) |

The five new mutants: the measured refusal ignored; a failure read as room coming
back; the disk's sentence thrown away for a fixed one; a copy routed to the
simulator service; the freed room measured again instead of carried.

## Part 3 — The adapters that touch the machine (infra), 2026-09-13

| reading | value |
|---|---|
| tests, infra package | 33 in 4 suites (engine still 49) |
| how long the tests take, tests alone | 0.034 s infra, 0.002 s engine — the first reading where a suite is measurably slower than the runner's floor, because four of its tests launch a real process and eight write to a real disk |
| ten slowest tests | `aFolderThatCouldNotBeDeletedSaysWhatTheDiskSaid` 0.025 s, `aToolThatWroteBeforeItFailedIsNotReadAsAnAnswer` 0.024 s, `aToolThatIsNotThereFails` 0.022 s, `aRefusalCarriesWhatTheToolSaid` 0.021 s; the rest under 0.01 s. The four at the top are the four that run `/bin/sh`. |
| ten pieces with the most branches | `FileManagerDisk.bytesUsedByFolder(at:)` 4, `MeasureLeftovers.refusal(for:)` 3, `DeleteLeftover.remove(_:)` 2, `DeleteLeftover.delete(_:)` 2; every other piece 1 |
| coverage, infra package | regions 97.53%, functions 97.78%, lines 98.97% |
| mutation tally beside it | 15 by hand on infra: 13 killed, 1 pardoned, 1 deleted as excess. Engine unchanged at 11/11. |

Coverage is not 100% here and the two missing regions are named: the `guard let`
around `FileManager.enumerator`, which never returns nil for any URL, and the
`?? 0` behind `totalFileAllocatedSize`, which a regular file always carries. Both
are optionals the API declares and the world does not produce.

The pardon: dropping `read.isRegularFile == true` from the walk's guard changes
nothing observable, because a folder reports no allocated size at all —
`totalFileAllocatedSize` and `fileAllocatedSize` are both nil for a directory,
measured 2026-09-13 — so counting folders adds zero. The test is not toothless:
the second falsification of the same rule, counting only what is *not* a regular
file, dies at exit 1.
