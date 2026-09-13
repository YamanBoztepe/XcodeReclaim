# Mutation, by hand

The sweep is closed. While it ran, this file was the journal that let it be
picked up again — the plan, and one row per mutant with the rule it falsifies and
the verdict — so a session that died mid-sweep cost nothing. Those two tables have
done their work and are in this file's git history; what is kept below is what
does not go stale: what the sweep cost, what it could not kill and why, and what
is held by something other than a test.

Every verdict was the runner's exit code, never a search of its output, and the
runner built first: a mutant that does not compile has not been judged. A
module's line was judged by that module's own suite, run from inside that
module's package.

## The tally

The whole sweep was run again, one mutant at a time, after a defect was found in
the runner itself: it judged by the exit code alone, and a mutant that *failed to
compile* also exits non-zero, so a mutant that was never judged was being written
down as killed. The runner now builds first and says **"did not compile — not a
mutant"**; three rows in this file had been recorded on runs that never happened.
All three were rewritten so they compile, and all three then died — the
conclusions held, the evidence did not.

**112 mutants across 21 production files, every one re-judged.**

- **108 killed.**
- **3 pardoned**, each with its sentence below.
- **1 survives with no answer**: the machine-side wiring in `XcodeLeftovers` can
  free a leftover's room without asking `DeleteLeftover` at all, and nothing goes
  red — the acceptance suite puts a spy where the machine is. See "What no suite
  can judge".
- **2 were answered earlier by deleting the code** rather than the mutant; that
  code is gone, so those two are history rather than rows.

The re-run found one more thing, and it is the reason for running it: the
`LeftoverListUIModel` refactor silently took the teeth out of a test. "Nothing to
delete is said while measuring too" had been killed by a test that called `open()`
— and after the refactor `open()` no longer redraws, so the test passed either
way. The test now refreshes over a finished measuring, and the mutant dies again.

One further change was discarded rather than judged: adding an unused case to
`Deletion` falsifies no rule, so it is a typo, not a mutant (rule 1).

## The pardons

**`FileManagerDisk`, `read.isRegularFile == true`.** A folder reports no
allocated size at all — `totalFileAllocatedSize` and `fileAllocatedSize` are both
nil for a directory, measured on this machine 2026-09-13 — so counting folders
adds zero and nothing can see the guard go. The guard's direction is held: the
second falsification, counting only what is *not* a regular file, dies at exit 1.

**`FileManagerDisk`, `paths > 1`.** Sending every file through the already-counted
set gives the same answer, because each file's resource identifier is its own;
the comparison is a cost boundary — it keeps a set of a million entries from
being built for derived data — and not a behaviour boundary. The behaviour is
held: never deduplicating at all dies at exit 1.

**`SystemXcodeCopies`, `lines(of: answered).first`.** `xcode-select -p` writes one
line, and the copy is chosen by asking whether the developer folder it names
starts with the copy's path — a trailing newline cannot change the start of a
string, so reading the whole answer instead of its first line gives the same
verdict. The rule is held: never asking the tools at all dies at exit 1.

## What no suite can judge

**`XcodeLeftovers.swift`** — the one file where the product meets the thread and the
real machine. It builds `FileManagerDisk`, `ProcessTool`,
`SimctlSimulatorService` and `SystemXcodeCopies`, names the folders Xcode leaves
things in, declares that 100 MB is worth deleting, and hops the answers back to
the screen. No unit suite can enter it: reaching it would mean either widening
its access for the tests alone (D31) or running a real forty-second measuring
inside the suite. It is judged by the running product instead, and the evidence
for that is owed by QA, not by this file.

**`XcodeReclaimApp.swift`** — the entry point. Same answer.

**`LeftoverListUIComposer.swift`** — one expression with no branch in it.

**`LeftoverListView.swift`** — judged, since the review, by seven recorded
snapshots as well as the two layout mutants, and every one of the nine dies.
SwiftUI's accessibility tree is still not reachable from inside the process —
measured 2026-09-13: an `NSHostingView` in a key window reports zero
accessibility children and no labels — so what the view *says* is read back from
its pixels rather than from its words.

**`LatestMeasuringOnlyDecorator`'s announce guard.** Its twin, the deliver guard,
is held by "A measuring the screen has replaced does not reach it". The announce
guard needs a stale *announcement* to arrive after a refresh, and a machine that
announces after being let go — which is the opposite of what the same double must
do for "The developer watches the measuring work through the leftovers", where
the announcements must land while the measuring is still held. Holding both
meanings took two doubles, two pairs of semaphores and a lock, and the owner
refused that complexity — rightly: the guard it bought protects a leftover's name
flashing on screen for an instant during a refresh. The deliver guard, which
protects a stale list replacing the screen, stays held.

**`MainThreadDecorator`'s hop back to the screen** — held by the compiler, not
by a test. Measured 2026-09-13: taking the hop out of `callAsFunction` and
calling the decoratee straight gives `error: main actor-isolated property
'decoratee' can not be referenced from a nonisolated context`, so the mutant
never runs. Its twin, the hop *away* in `answer(from:)`, does compile and is
killed by "the measuring runs away from the screen's thread" — judged with only
that test, because running the measuring on the screen's thread deadlocks the two
tests that hold a measuring at a gate, and a suite that never finishes is not a
verdict.

**`XcodeLeftovers`'s machine-side properties, `MainThreadDecorator` and
`WhereXcodeLeavesThings`** — the wiring that names the folders Xcode leaves
things in, builds the four adapters, and carries the answers back across the
thread boundary. The acceptance suite puts a spy exactly where that wiring sits,
so nothing can judge it: a mutant that frees a leftover's room without asking
`DeleteLeftover` at all survives. It is judged by running the product instead,
and the evidence for that is owed by QA.

The crossing types that used to sit here are gone. Declaring `Sendable` on the
core values — measured 2026-09-13: a checked `@retroactive Sendable` in the app
target compiles and carries `[Leftover]` across a `Task.detached` boundary, but
`swift-format`'s `AvoidRetroactiveConformances` refuses it — removed 86 lines
that mirrored the models and the one mutant no suite could reach.
