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

## Part 4 — What the screen holds (presentation), 2026-09-13

| reading | value |
|---|---|
| tests, presentation package | 44 in 4 suites (engine 49, infra 33 — 126 together) |
| how long the tests take, tests alone | 0.001 s presentation, 0.034 s infra, 0.002 s engine |
| ten slowest tests | every presentation test at 0.001 s; the suite's whole run is still under the runner's resolution. The four `/bin/sh` tests in infra remain the only ones that cost anything. |
| ten pieces with the most branches | `FileManagerDisk.bytesUsedByFolder(at:)` 4; `LeftoverListViewModel.whyItCannotBeDeleted(_:)`, `.identity(of:)`, `.kind(of:)` and `MeasureLeftovers.refusal(for:)` 3; four pieces at 2; every other piece 1 |
| coverage, presentation package | regions 100.00%, functions 100.00%, lines 100.00% (96 regions, 48 functions, 209 lines) |
| mutation tally beside it | 16 by hand on presentation: 14 killed, 1 deleted as excess, 1 leak-tracker sabotage killed. Running total 42 mutants, 38 killed, 1 pardoned, 2 deleted as excess. |

The excess: `deletionEnded(with:)` carried `guard !isMeasuring else { return }` to stop a
finished deletion putting the old list back, but `refresh()` already clears what the last
measuring found, so the guard could be removed with every test still green. The rule is held
structurally rather than checked — proved by the second falsification, making `refresh()`
keep the old list, which dies at exit 1.

The leak tracking is not decorative: keeping the view model alive past the end of a test
turns the suite red (exit 1).

## Part 5 — The screen, the composition root and the journeys (ui + app), 2026-09-13

| reading | value |
|---|---|
| tests | 13 in the app target; 126 in the packages (engine 49, infra 33, presentation 44) — 139 together |
| how long the tests take, tests alone | app target 0.18 s of test time; packages 0.037 s |
| ten slowest tests | `everyMeasuredLeftoverIsDrawnWithItsSize` 0.082 s, `theScreenAsksForNoMoreHeightThanAWindowCanGive` 0.060 s, `theScreenDoesNotKeepTheCompositionRootAlive` 0.035 s, then everything under 0.0005 s. The top three lay a SwiftUI view out in a real window; the four `/bin/sh` tests in infra are next. |
| ten pieces with the most branches | unchanged: `FileManagerDisk.bytesUsedByFolder(at:)` 4; four pieces at 3; five at 2 |
| coverage | engine 100%, presentation 100%, infra 97.53% (two named API artifacts). The app target's coverage is not read here — the crossings and the root are judged by mutation below, which is the reading that matters. |
| mutation tally beside it | 10 by hand on ui + app: 9 killed, 1 survived and then killed after the missing test was written. Running total 52 mutants, 49 killed, 1 pardoned, 2 deleted as excess. |

Two findings a test made rather than a reading. The screen asked to be 2650 points
tall for sixty rows — the very defect feature 04 records — and the survivor was a
crossing that could turn a copy of Xcode into a folder with nothing noticing,
because the acceptance suite stopped at the root's edge. The crossings are now the
root's own currency, so every journey crosses, and the round trip has a test of its own.

## After the owner's review — dummy view, adapters, snapshots, 2026-09-13

| reading | value |
|---|---|
| tests | 147 — engine 49, infra 35, presentation 45, ui 9, app 9 (was 142) |
| how long the tests take, tests alone | ui 0.373 s, infra 0.080 s, presentation 0.002 s, engine 0.002 s; the app target 0.16 s |
| ten slowest tests | every one of the ui package's nine, 0.13–0.34 s each — they lay a SwiftUI view out in a real window and read its pixels back. The suite's whole cost is now the snapshots, and that is the first reading where one suite costs more than all the others together. |
| ten pieces with the most branches | `FileManagerDisk.bytesUsedByFolder(at:)` 4; three pieces of `LeftoverListViewModel`, `MeasureLeftovers.refusal(for:)` and the three crossing conversions at 3 |
| coverage, presentation package | regions 100.00%, functions 100.00%, lines 100.00% (99 regions, 49 functions, 231 lines) |
| mutation tally beside it | 13 new by hand: 7 on the view, judged by the snapshot suite, and 6 on the adapters and the decorator, judged by the app suite — all 13 killed. Running total 109 mutants, 104 killed, 3 pardoned, 2 deleted as excess. |
| what went the other way | one mutant that used to die now survives: turning a copy of Xcode into a folder inside `LeftoverCrossing`. The crossings are internal now, so no suite can reach them. |

The snapshot suite is not decorative: seven deliberate defects in the view — the
capacity bar gone, a row's refusal not drawn, the row being deleted still showing
its size, a refused row still offering its button, the largest row unmarked, a
section's symbol dropped, "Nothing to delete." missing — every one of them turns
the suite red on the recorded pixels.
