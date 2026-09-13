# Vital signs

Four readings, appended and never regenerated. One reading says nothing; a series
says something. These are observations, not targets.

## How long the tests take, tests alone

| reading | engine | infra | presentation | ui | app |
|---|---|---|---|---|---|
| 1 — measure leftovers | 0.001 s / 37 | — | — | — | — |
| 2 — delete leftover | 0.002 s / 49 | — | — | — | — |
| 3 — the adapters | 0.002 s / 49 | 0.034 s / 33 | — | — | — |
| 4 — what the screen holds | 0.002 s / 49 | 0.034 s / 33 | 0.001 s / 44 | — | — |
| 5 — the screen and the root | 0.002 s / 49 | 0.034 s / 33 | 0.001 s / 44 | — | 0.18 s / 13 |
| 6 — after the first review | 0.002 s / 49 | 0.080 s / 35 | 0.002 s / 45 | 0.373 s / 9 | 0.16 s / 13 |
| 7 — after the second review | 0.002 s / 49 | 0.080 s / 35 | 0.002 s / 45 | 0.373 s / 9 | 0.16 s / 13 |
| 8 — after the third review | 0.002 s / 49 | 0.074 s / 35 | 0.002 s / 45 | 0.406 s / 9 | 0.17 s / 16 |
| 9 — after the fourth review | 0.002 s / 49 | 0.070 s / 35 | 0.002 s / 45 | 0.355 s / 9 | 0.25 s / 17 |
| 10 — after the fifth review | 0.002 s / 49 | 0.070 s / 35 | 0.001 s / 45 | 0.355 s / 9 | 0.61 s / 21 |

## The ten slowest tests

| reading | test | time |
|---|---|---|
| 3 | `removeItem_throwsWhatTheDiskSaid…` (infra) | 0.025 s |
| 3 | `run_throwsWhenTheToolWroteBeforeItFailed` (infra) | 0.024 s |
| 3 | `run_throwsWhenTheToolIsNotThere` (infra) | 0.022 s |
| 3 | `run_throwsWhatTheToolSaidWhenItExitsWithAFailure` (infra) | 0.021 s |
| 5 | `draws_everyLeftoverItWasGiven…` (app, then ui) | 0.082 s |
| 5 | `draws_noMoreHeightThanAWindowCanGive` (app, then ui) | 0.060 s |
| 6 | every one of the ui package's nine | 0.13–0.34 s |
| 10 | "A screen with nothing to delete says so" (ui) | 0.319 s |
| 10 | "A screen with a deletion under way…" (ui) | 0.319 s |
| 10 | "The developer deletes a leftover" (app) | 0.140 s |
| 10 | "The developer refreshes the list" (app) | 0.130 s |

## The ten pieces with the most branches

| reading | piece | branches |
|---|---|---|
| 1 | `MeasureLeftovers.refusal(for:)` | 3 |
| 2 | `DeleteLeftover.remove(_:)` | 3 |
| 3 | `FileManagerDisk.bytesUsedByFolder(at:)` | 4 |
| 4 | `LeftoverListViewModel.whyItCannotBeDeleted(_:)`, `.identity(of:)`, `.kind(of:)` | 3 each |
| 10 | `FileManagerDisk.bytesUsedByFolder(at:)` | 4 |
| 10 | `MeasureLeftovers.refusal(for:)` | 3 |
| 10 | `LeftoverListViewModel` — three pieces | 3 each |
| 10 | `LeftoverListViewModel` — two pieces, `LeftoverListView.drawn(_:)` | 2 each |
| 10 | every other piece | 1 |

## Coverage, beside the mutation tally

| reading | engine | infra | presentation | mutants | killed | pardoned | excess | survived |
|---|---|---|---|---|---|---|---|---|
| 1 | 100% | — | — | 6 | 6 | 0 | 0 | 0 |
| 2 | 100% | — | — | 11 | 11 | 0 | 0 | 0 |
| 3 | 100% | 97.53% | — | 26 | 24 | 1 | 1 | 0 |
| 4 | 100% | 97.53% | 100% | 42 | 38 | 1 | 2 | 0 |
| 5 | 100% | 97.53% | 100% | 52 | 49 | 1 | 2 | 0 |
| 6 (re-judged from scratch) | 100% | 97.53% | 100% | 112 | 108 | 3 | 2 | 1 |
