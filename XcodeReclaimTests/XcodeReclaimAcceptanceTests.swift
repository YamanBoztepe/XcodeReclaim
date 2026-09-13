import AppKit
import Foundation
import Testing

@MainActor
struct XcodeReclaimAcceptanceTests {
    @Test("The developer opens the app and sees what may be deleted")
    func open_showsEveryLeftoverWithItsSize() async {
        let app = appMeasuring(foldersHolding: [derivedDataFolder: 300], simulatorsTaking: [200])

        app.open()
        #expect(app.isMeasuring)
        #expect(app.shownLeftovers.isEmpty)

        await app.waitForMeasuringToEnd()
        #expect(app.shownLeftovers == ["Derived data — 300 bytes", "iPhone 17 (iOS 26.4, 21B507D3) — 200 bytes"])
    }

    @Test("The developer deletes a leftover")
    func confirm_takesTheDeletedLeftoverOffTheScreen() async throws {
        let app = appMeasuring(foldersHolding: [derivedDataFolder: 300], simulatorsTaking: [200])
        app.open()
        await app.waitForMeasuringToEnd()

        try app.askToDelete("Derived data")
        #expect(app.leftoverAwaitingConfirmation == "Derived data")

        app.confirm()
        #expect(app.leftoverAwaitingConfirmation == nil)
        #expect(app.rowsBeingDeleted == ["Derived data"])
        #expect(app.deletableRows.isEmpty)

        await app.waitForDeletionToEnd()
        #expect(app.shownLeftovers == ["iPhone 17 (iOS 26.4, 21B507D3) — 200 bytes"])
        #expect(app.deletionMessage == "300 bytes came back.")
    }

    @Test("A deletion the developer backs out of leaves the leftover as it was")
    func backOut_leavesTheLeftoverAsItWas() async throws {
        let app = appMeasuring(foldersHolding: [derivedDataFolder: 300])
        app.open()
        await app.waitForMeasuringToEnd()

        try app.askToDelete("Derived data")
        #expect(app.leftoverAwaitingConfirmation == "Derived data")

        app.backOut()
        #expect(app.leftoverAwaitingConfirmation == nil)
        #expect(app.shownLeftovers == ["Derived data — 300 bytes"])
        #expect(app.deletionMessage == nil)
    }

    @Test("The developer refreshes the list")
    func refresh_showsEveryLeftoverTheSecondMeasuringFound() async {
        let app = appMeasuring(foldersHolding: [derivedDataFolder: 300], simulatorsTaking: [200])
        app.open()
        await app.waitForMeasuringToEnd()

        app.refresh()
        #expect(app.isMeasuring)
        #expect(app.shownLeftovers.isEmpty)

        await app.waitForMeasuringToEnd()
        #expect(app.shownLeftovers == ["Derived data — 300 bytes", "iPhone 17 (iOS 26.4, 21B507D3) — 200 bytes"])
    }

    @Test("The developer deletes a copy of Xcode they no longer use")
    func confirm_takesTheDeletedCopyOfXcodeOffTheScreenAndSaysWhatCameBack() async throws {
        let app = appMeasuring(foldersHolding: [derivedDataFolder: 300], copiesOfXcodeTaking: [4_000_000_000])
        app.open()
        await app.waitForMeasuringToEnd()

        try app.askToDelete("Xcode 26.2 (17C51) — Applications")
        #expect(app.confirmationMessage == "Frees 4.0 GB. That version has to be downloaded again. This cannot be undone.")

        app.confirm()
        await app.waitForDeletionToEnd()
        #expect(app.shownLeftovers == ["Derived data — 300 bytes"])
        #expect(app.deletionMessage == "4.0 GB came back.")
    }

    @Test("The folders the machine offers are measured at once rather than one after another")
    func open_measuresTheFoldersAtOnce() async {
        let twoOfTheFolders = [derivedDataFolder, previewsFolder]
        let disk = DiskSpy()
        let app = appMeasuring(withDisk: disk)

        app.open()
        await app.waitUntil { twoOfTheFolders.allSatisfy(disk.foldersAskedAbout.contains) }
        disk.answerNow()

        #expect(twoOfTheFolders.allSatisfy(disk.foldersAskedAbout.contains))
        await app.waitForMeasuringToEnd()
    }

    @Test("Leftovers of equal size are shown in the order the machine offers them")
    func open_showsLeftoversOfEqualSizeInTheOrderTheyAreOffered() async {
        let roomTheyBothTake = 300
        let app = appMeasuring(foldersHolding: [previewsFolder: roomTheyBothTake, derivedDataFolder: roomTheyBothTake])

        app.open()
        await app.waitForMeasuringToEnd()

        #expect(app.shownLeftovers == ["Derived data — 300 bytes", "Previews — 300 bytes"])
    }

    @Test("The developer opens the app and it takes its place among the regular applications")
    func open_takesItsPlaceAmongTheRegularApplications() {
        #expect(NSApplication.shared.activationPolicy() == .regular)
        #expect(Bundle.main.object(forInfoDictionaryKey: "LSUIElement") == nil)
    }
}
