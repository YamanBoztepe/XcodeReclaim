# Handover

Written 2026-09-13, at `fcc68f1`, after running the built product against this
machine.

## What the running product showed

Built for release, launched, and left to measure the real machine. Everything
below was read off the screen and then checked against the world with `du`,
`simctl`, `mdfind`, `ps` and `xcode-select` — not taken on trust.

| what the screen said | what the world says |
|---|---|
| 196.3 GB to reclaim | 94.6 + 85.8 + 15.9, the three sections it drew |
| iPhone 17 (iOS 26.4, 9F802260) — 13.7 GB | `du -sk` on that device folder: 13 380 776 KB = 13.7 GB |
| three simulators refused, "The simulator is running." | `simctl` reports exactly those three as Booted |
| Caches and support files 85.8 GB | derived data 45.6, ib cache 6.7, device support 28.4, previews 3.7, documentation 1.6 |
| Xcode versions 15.9 GB | the four copies `mdfind` reports: 4.0 + 4.0 + 3.9 + 3.9 |
| "Xcode 26.4.1 (17E201) — Applications", "Xcode is open." | `ps` shows Xcode running from `/Applications/Xcode.app` |
| "Xcode 26.1.1 (17B55) — Desktop" | there is a fourth copy on the Desktop that a folder listing of `/Applications` would never have found |
| "Derived data" carries "Holds the most room" | 45.6 GB is the largest single leftover on the machine |
| "iPad Air 11-inch (M3) … 323.1 MB" | a size under a gigabyte, written in megabytes |

The measuring ran without freezing the screen, named each leftover as it reached
it — "Device support (iOS 26.5)", "Apple Watch SE (40mm) (2nd generation)
(watchOS 11.1, 43035EC3)" — and the Refresh button stayed disabled until it
finished. That is the wiring in `XcodeLeftovers` that no suite can judge, seen
working.

**The one scenario not exercised: deleting.** The product deletes what cannot be
undone, and the only things on this machine to delete are the owner's. It needs
a word from the owner before it is tried, and it should be tried on something
chosen deliberately — a small simulator, not derived data.

## How long the measuring takes

Measured on this machine, with the product's own code:

| what it walks | before | now |
|---|---|---|
| simulators, 114 folders | 73 s | **0.6 s** — `simctl` reports `dataPathSize`, so nothing is walked |
| derived data, 45.6 GB | 47.9 s | 47.9 s, and it now runs beside the others |
| copies of Xcode | 26.6 s | 26.6 s, beside the others |
| everything | ~157 s | **49.6 s** in the probe, **61 s** in the running app |

Two changes bought it. The simulator sizes come from `simctl` rather than from
walking every device folder, and the sources run together rather than one after
another — `MeasureLeftovers` takes a `running:` function, the app target hands it
one that runs them at once, and the engine still holds no threading word of its
own. What is left is the floor: derived data alone takes 48 s and everything else
now hides behind it.

**The cost of the first change is accuracy.** `dataPathSize` is what the simulator
service already knows rather than what the disk holds: exact on small devices,
about 8–11% low on large ones. The screen said 94.6 GB of simulators before and
84.3 GB now; one device read 13.7 GB and now reads 13.3 GB. The owner chose this
trade knowingly.

## Two notes from watching it

- The window opens at 900×450 and the simulator list is long enough that the
  other two sections are well below the fold. Nothing in the feature files asks
  for more, so this is an observation rather than a defect.
- A copy of Xcode is sitting on the Desktop taking 3.9 GB. The product found it
  because it asks Spotlight rather than reading `/Applications`.

## What stands without a test

- **The machine-side wiring in `XcodeLeftovers`.** A mutant that frees a
  leftover's room without asking `DeleteLeftover` survives every suite; the
  acceptance suite puts a double exactly where that wiring sits. It is judged by
  the run above.
- **`LatestMeasuringOnly`'s announce guard.** Recorded in `mutants/app.sh` with
  its reason: catching a stale announcement needs a double that announces after
  being let go, which is the opposite of what the same double must do for the
  test beside it. Its twin, the deliver guard, is held.
- **Three pardoned mutants in infra**, each with its sentence in
  `mutants/infra.sh`: a directory reports no allocated size on APFS; the
  hard-link boundary is a cost boundary rather than a behaviour one; and
  `xcode-select -p` writes a single line.
- **The hop back to the screen** is held by the compiler rather than by a test —
  taking it out of `MainThreadDecorator` does not compile.

## Decisions waiting

1. **Dead simulators.** `simctl` can report a device whose runtime is gone. They
   are listed like any other today.
2. **A tool that fails silently.** If `simctl` or `mdfind` exits non-zero with
   nothing on its error channel, the sentence the screen shows is empty.
3. **`ps` or `xcode-select` unavailable.** A copy is then neither open nor
   pointed at, so it is offered for deletion.
4. **A copy carrying a version but no build.** It is named "Xcode — where it
   sits", dropping the version it does have.
5. **Deleting for real** — see above.
