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
