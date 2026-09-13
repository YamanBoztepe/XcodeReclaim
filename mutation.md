# Mutation, by hand

Every production file is on this list, and the composition root is on it first.
A module's line is judged by that module's own suite, run from inside that
module's package; the app target's lines are judged by the app target's suite.
Every verdict below is the runner's exit code, never a search of its output.

## The plan

| file | mutants planned | suite that judges it | done |
|---|---|---|---|
| XcodeReclaim/LatestMeasuringOnlyDecorator.swift | 3 | app target | 3 |
| XcodeReclaim/LeftoverListContainerView.swift | 4 | app target | 4 |
| XcodeReclaim/XcodeLeftovers.swift, the machine-side half | 3 | none — see below | 1, and it survives |
| XcodeReclaim/LeftoverListUIComposer.swift | 1 | app target | 0 |
| XcodeReclaim/XcodeReclaimApp.swift | 1 | none — the entry point | 0 |
| Core/Leftover.swift | 2 | engine package | 2 |
| Core/Deletion.swift | 1 | engine package | 0 |
| Engine/MeasureLeftovers.swift | 12 | engine package | 13 |
| Engine/DeleteLeftover.swift | 5 | engine package | 7 |
| Engine/Simulator.swift | 1 | engine package | 1 |
| Engine/XcodeCopy.swift | 1 | engine package | 1 |
| Engine/Disk.swift, SimulatorService.swift, XcodeCopies.swift | 0 — declarations only | — | 0 |
| Infra/FileManagerDisk.swift | 6 | infra package | 10 |
| Infra/ProcessTool.swift | 3 | infra package | 3 |
| Infra/SimctlSimulatorService.swift | 4 | infra package | 5 |
| Infra/SystemXcodeCopies.swift | 7 | infra package | 7 |
| Infra/Tool.swift | 0 — declaration only | — | 0 |
| Presentation/LeftoverListViewModel.swift | 14 | presentation package | 25 |
| Presentation/RoomAsAPersonReadsIt.swift | 4 | presentation package | 5 |
| Presentation/LeftoverRow.swift, LeftoverSection.swift | 1 | presentation package | 2 |
| UI/LeftoverListView.swift | 2 | app target — layout only | 2 |

## The mutants

| file:line | the rule it falsifies | suite run | verdict |
|---|---|---|---|
| MeasureLeftovers `bytes >= worthDeleting` | A leftover exactly at the threshold is delivered | engine | killed |
| MeasureLeftovers `offered.offset < other.offset` | Leftovers holding equal room keep the order they were offered in | engine | killed |
| MeasureLeftovers `isShutDown ? nil : .theSimulatorIsRunning` | A simulator that is not shut down is delivered as running | engine | killed |
| MeasureLeftovers `case (true, _): .xcodeIsOpen` | A copy both open and pointed at is delivered as open | engine | killed |
| MeasureLeftovers `"iOS \(read.1)"` | A device support version is named by the system version it holds, not by the device model | engine | killed |
| MeasureLeftovers `announce(folder.name)` moved below the size read | A leftover is announced before its size is read | engine | killed |
| MeasureLeftovers folder order | Every offered leftover is announced in the order the measuring works on them | engine | killed |
| MeasureLeftovers `(try? simulators()) ?? []` | The other leftovers are delivered even when the simulators cannot be listed | engine | killed |
| MeasureLeftovers `startOf(identifier)` | A simulator is named with the start of its device identifier | engine | killed |
| MeasureLeftovers `"Xcode — \(whereItSits)"` | A copy carrying no version is named by where it sits alone | engine | killed |
| MeasureLeftovers `deletingLastPathComponent()` | Where a copy sits is the folder holding it, not the bundle | engine | killed |
| MeasureLeftovers `"Xcode/iOS DeviceSupport"` | Device support is read from the folder device support sits in | engine | killed |
| MeasureLeftovers `"Xcode/UserData/IB Support"` | The interface builder cache is read from the folder it sits in | engine | killed |
| DeleteLeftover `if let refusal` | A leftover refused when it was measured is not deleted | engine | killed |
| DeleteLeftover `return .failed(...)` | A deletion the world refuses is never read as room coming back | engine | killed |
| DeleteLeftover `error.localizedDescription` | A copy that could not be removed says what the disk said | engine | killed |
| DeleteLeftover `case .folder, .xcodeCopy` | A copy of Xcode is removed from the disk, not from the simulator service | engine | killed |
| DeleteLeftover `.freed(leftover.bytes)` | A deletion frees the room the leftover was carrying and does not measure again | engine | killed |
| DeleteLeftover `case .simulator` | A simulator is deleted by telling the service, not by removing a folder | engine | killed |
| DeleteLeftover `.refused(refusal)` | A refusal is delivered as a refusal, not as a failure | engine | killed |
| Leftover `self.cost = cost` | A leftover carries the cost it was built with | engine | killed |
| Leftover `self.name = name` | A leftover carries the name it was built with | engine | killed |
| Simulator `self.name / self.runtime` | A simulator's name and its runtime are not interchangeable | engine | killed |
| XcodeCopy.Version `number / build` | A version's number and its build are not interchangeable | engine | killed |
| FileManagerDisk `countsOnce(...)` | A folder counts a file with more than one path once | infra | killed |
| FileManagerDisk `errorHandler: { _, _ in true }` | A folder that cannot be fully read is measured with what could be read | infra | killed |
| FileManagerDisk `read.isRegularFile == true` | Only a regular file's room is counted | infra | **pardoned** |
| FileManagerDisk `read.isRegularFile == false` (second falsification) | the same rule, the other way | infra | killed |
| FileManagerDisk `catch ... .fileNoSuchFile` | Only "it is not there" is forgiven; every other refusal is a failure | infra | killed |
| FileManagerDisk `catch` clause removed | Removing something that is not there is not a failure | infra | killed |
| FileManagerDisk `isDirectory == true` | Device support offers the folders it holds and nothing else | infra | killed |
| FileManagerDisk `options: []` | A folder counts what its subfolders hold | infra | killed after the missing test was written |
| FileManagerDisk `?? []` on the listing | A folder that cannot be read holds no folders | infra | killed after the missing test was written |
| FileManagerDisk `paths > 1` | A file with more than one path is counted once | infra | **pardoned** |
| FileManagerDisk `paths > 99` (second falsification) | the same rule, never deduplicating | infra | killed |
| ProcessTool `terminationStatus == 0` | A tool that exits with a failure is not read as an answer | infra | killed |
| ProcessTool `said` | A refusal carries what the tool said | infra | killed |
| ProcessTool `text(of: written)` | A tool's answer is what it wrote, not what it complained about | infra | killed |
| SimctlSimulatorService `state == "Shutdown"` | A device in any state other than Shutdown is not shut down | infra | killed |
| SimctlSimulatorService `joined(separator: ".")` | A runtime's version parts are read as a version | infra | killed |
| SimctlSimulatorService `sorted { $0.key < $1.key }` | The devices arrive in a settled order | infra | killed |
| SimctlSimulatorService `devicesFolder.appending(path: udid)` | A device is sized by its own folder | infra | killed |
| SimctlSimulatorService `["simctl", "delete", identifier]` | The service is told to delete the device it was asked about | infra | killed |
| SystemXcodeCopies `xcodeBundleIdentifier` | The search is asked for Xcode's own bundle identifier | infra | killed |
| SystemXcodeCopies `reported.isEmpty ? ... : reported` | The applications folder is read only when the search reports nothing | infra | killed |
| SystemXcodeCopies `reported.isEmpty ? reported : ...` | the same rule, the other way | infra | killed |
| SystemXcodeCopies `lines(of: answered).first` | The copy the tools point at is the one holding the developer folder they name | infra | **pardoned** |
| SystemXcodeCopies `return ""` (second falsification) | the same rule, never asking | infra | killed |
| SystemXcodeCopies `inside(app)` trailing slash | A copy whose whole name starts another copy's name is not the one that is running | infra | killed |
| SystemXcodeCopies `.map(spelledOneWay)` | One place is spelled one way | infra | killed |
| SystemXcodeCopies `DTXcodeBuild` required | A copy whose bundle declares no build carries no version | infra | killed |
| SystemXcodeCopies `split(whereSeparator: \.isNewline)` | A search answering over several lines reports every copy it named | infra | killed |
| LeftoverListViewModel `open()` calls `measure()` | An opened screen asks for a measuring | presentation | killed |
| LeftoverListViewModel `refresh()` calls `measure()` | A refresh measures again | presentation | killed |
| LeftoverListViewModel `isMeasuring = false` | A finished measuring is no longer measuring | presentation | killed |
| LeftoverListViewModel `leftoverBeingMeasured = nil` | A screen that has finished measuring names no leftover being measured | presentation | killed |
| LeftoverListViewModel `!isMeasuring && sections.isEmpty` | A measuring screen does not say there is nothing to delete | presentation | killed |
| LeftoverListViewModel `backOut()` clears the confirmation | A deletion the developer backs out of leaves the screen asking nothing | presentation | killed |
| LeftoverListViewModel `confirm()` clears the confirmation | A confirmed deletion is no longer asked about | presentation | killed after the missing test was written |
| LeftoverListViewModel `confirm()` clears the last sentence | — no scenario draws this line | presentation | **deleted as excess** |
| LeftoverListViewModel `identity(of: $0.place) == row.id` | A row is asked about by where it sits, not by its name | presentation | killed |
| LeftoverListViewModel `leftovers.isEmpty ? nil` | A screen with nothing to delete has nothing to reclaim | presentation | killed |
| LeftoverListViewModel `kind(of:)` | A simulator and a folder are shown in different sections | presentation | killed |
| LeftoverListViewModel `.freed(let bytes)` | A finished deletion says what came back, not what the row held | presentation | killed after the fixture was made to discriminate |
| LeftoverListViewModel `"\(deleted.name) could not be deleted."` | A failed deletion names the leftover it failed on | presentation | killed |
| LeftoverListViewModel `sorted { roomIn > roomIn }` | The section holding the most room is shown first | presentation | killed |
| LeftoverListViewModel `shown.count > 1` | A screen with one leftover marks nothing | presentation | killed |
| LeftoverListViewModel `shown.first { ... }` | Leftovers holding the same room mark only the one shown first | presentation | killed |
| LeftoverListViewModel `beingDeleted == nil` | A deletion under way offers no other deletion until it ends | presentation | killed |
| LeftoverListViewModel `guard !isMeasuring` in `deletionEnded` | A deletion that ends while measuring does not put the old list back | presentation | **deleted as excess** |
| LeftoverListViewModel `refresh()` clears the leftovers (second falsification) | the same rule, held structurally | presentation | killed |
| LeftoverListViewModel `if case .freed` | A leftover that could not be deleted stays on the screen | presentation | killed |
| LeftoverListViewModel `roomRounded` in the total | The room to reclaim is what the sections say they hold | presentation | killed |
| LeftoverListViewModel `refresh()` clears the last sentence | A refresh says nothing about the deletion before it | presentation | killed |
| LeftoverListViewModel `leftover.refusal == nil` in `askAboutDeleting` | A running simulator is not confirmed | presentation | killed |
| LeftoverListViewModel `asASentence(cost)` | A confirmation reads as sentences | presentation | killed |
| LeftoverListViewModel `.filter { !$0.held.isEmpty }` | A section the measuring found nothing for is not shown | presentation | killed |
| LeftoverListViewModel `/ Double(roomOnTheScreen)` | A section's share is of the room on the screen | presentation | killed |
| RoomAsAPersonReadsIt `roundingUpFromAHalf` | A size is rounded, not truncated | presentation | killed |
| RoomAsAPersonReadsIt `units.first(where:)` | A size is shown in the unit its magnitude asks for | presentation | killed |
| RoomAsAPersonReadsIt `bytes >= $0.divisor` | A size below a thousand is written in bytes | presentation | killed |
| RoomAsAPersonReadsIt `read.tenths % tenthsPerUnit` | A size carries its tenth | presentation | killed |
| RoomAsAPersonReadsIt `read.tenths * (divisor / tenths)` | A rounded size is still a size in bytes | presentation | killed |
| LeftoverRow `self.canBeDeleted` | A row carries whether it can be deleted | presentation | killed |
| LeftoverSection `self.share` | A section carries the share it was built with | presentation | killed |
| the suite's own leak tracker (sabotage) | The view model is released when the test ends | presentation | killed |
| LeftoverListView `.frame(idealHeight:)` | The screen asks for no more height than a window can give | ui | killed |
| LeftoverListView `ForEach(section.rows)` | Every measured leftover is drawn | ui | killed |
| LeftoverListView `capacityBar` | A measured screen draws its capacity bar | ui (snapshot) | killed |
| LeftoverListView `if let refusal = row.refusal` | A row says under its name why it cannot be deleted | ui (snapshot) | killed |
| LeftoverListView `row.deletionUnderWay ?? row.size` | A row being deleted says so where its size was | ui (snapshot) | killed |
| LeftoverListView `.disabled(!row.canBeDeleted)` | A row that cannot be deleted offers no button | ui (snapshot) | killed |
| LeftoverListView `if row.holdsTheMostRoom` | The row holding the most room is marked | ui (snapshot) | killed |
| LeftoverListView `Label(section.name, systemImage:)` | A section draws the symbol that names it | ui (snapshot) | killed |
| LeftoverListView `if model.nothingToDelete` | A screen with nothing to delete says so | ui (snapshot) | killed |
| LatestMeasuringOnlyDecorator the guard around `deliver` | A measuring the screen has replaced does not reach it | app | killed |
| LatestMeasuringOnlyDecorator the guard around `announce` | nor do its announcements | app | killed |
| LeftoverListUIComposer `delivering:` | What the machine measured reaches the screen | app | killed |
| LeftoverListUIComposer `announcing:` | What the machine is working on reaches the screen | app | killed |
| LeftoverListUIComposer the deletion's callback | A deletion's outcome reaches the screen | app | killed |
| LeftoverListUIComposer `latestOnly.measure(...)` | An opened screen asks for a measuring | app | killed |
| WeakReference `weak var object` | The wiring does not keep the screen alive | app | killed |
| LeftoverListContainerView each of its four wires | The container binds the screen's inputs to the view model | app | killed |
| LatestMeasuringOnlyDecorator `latestMeasuring += 1` | Each measuring is a new one | app | killed |
| LeftoverListView `Text(model.title)` | The screen draws the title it was given | ui (snapshot) | killed |
| LeftoverListView `if model.isMeasuring` | A measuring screen says so | ui (snapshot) | killed |
| LeftoverListView `if let being = model.leftoverBeingMeasured` | A measuring screen names what it is working on | ui (snapshot) | killed |
| LeftoverListView `if let said = model.whatTheDeletionSaid` | A screen after a deletion says what came back | ui (snapshot) | killed |
| LeftoverListView `Text(section.element.size)` | The bar's key says how much each section holds | ui (snapshot) | killed |
| LeftoverListUIModel `whatTheDeletionSaid` | The drawn model carries what the deletion said | presentation | killed |
| LeftoverListViewModel `deletionUnderWay` | A row being deleted says so | presentation | killed |
| XcodeLeftovers `whatCameBack(from:in:)` | A deletion is what the deleter did, not what was asked for | none | **survives — no suite reaches the machine** |

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

**`TheMachine.swift`** — the one file where the product meets the thread and the
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

**`XcodeLeftovers`'s two machine-side functions, `MainThreadDecorator` and
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
