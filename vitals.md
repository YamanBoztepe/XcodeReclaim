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
