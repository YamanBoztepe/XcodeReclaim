# XcodeReclaim

[![CI](https://github.com/YamanBoztepe/XcodeReclaim/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/YamanBoztepe/XcodeReclaim/actions/workflows/ci.yml)
![Tests](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2FYamanBoztepe%2FXcodeReclaim%2Fbadges%2Ftests.json)
![Coverage](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2FYamanBoztepe%2FXcodeReclaim%2Fbadges%2Fcoverage.json)

A macOS app that shows what Xcode has left on disk — where it sits and how much
room it takes — and deletes what you choose.

![The leftover list](screenshot.png)

Xcode leaves derived data, previews, interface builder caches, documentation
caches and device support folders behind; it keeps every simulator you have ever
made; and every copy of Xcode you have downloaded stays where you put it. This
app measures all of it, shows it in one list with the room each one holds, and
deletes the ones you pick — one at a time or several at once.

## What it will not do

**Nothing goes to the trash.** The point is the room, and the trash holds on to
it, so every deletion is permanent. That is why every deletion is confirmed
first, and why the confirmation says what it costs rather than only what it
frees: a simulator takes the apps inside it with it, a copy of Xcode has to be
downloaded again.

It never offers your provisioning profiles, your archives or your settings.

It refuses what it should not touch, and says why in the row: a simulator that is
running, a copy of Xcode that is open, and the copy your command line tools point
at.

## Building it

It needs macOS 15 or later to run and Xcode 26 to build. There is no signed
download yet, so build it yourself — the Xcode project is generated rather than
kept in the repository:

```bash
brew install xcodegen swiftlint
git lfs install && git lfs pull
xcodegen generate
open XcodeReclaim.xcodeproj
```

Then ⌘R.

`git lfs` matters: the UI snapshots are stored with it, and without pulling them
the snapshot tests compare against pointer files. `swift-format` ships with
Xcode; both it and `swiftlint` run clean on the tree.

Tests are ⌘U for the app and its journeys, and `swift test` inside each folder
under `Packages/` for the layers underneath. Every test is named for what it
claims, so the suite reads as a list of sentences about the product. The
snapshot tests compare real pixels, so they refuse to judge on a different
macOS than the one they were recorded on, and say so rather than failing
quietly.

## How it is put together

Each layer is its own package and knows only the one below it. The screen
decides nothing, the engine knows nothing about a screen or a disk, and every
decision about threads is taken in one place.

| where | what is in it |
|---|---|
| `Packages/XcodeReclaimCore` | the two values every layer agrees on |
| `Packages/XcodeReclaimEngine` | measuring and deleting, with no idea of a screen or a disk |
| `Packages/XcodeReclaimInfra` | the real disk, `simctl`, `mdfind` and `xcode-select` |
| `Packages/XcodeReclaimPresentation` | what the screen says, as values |
| `Packages/XcodeReclaimUI` | the SwiftUI screen, which is handed a model and closures |
| `XcodeReclaim` | the composition root: where the parts meet, and where threading lives |
| `XcodeReclaimTests` | the journeys through the whole app |

## Licence

MIT — see [LICENSE](LICENSE).
