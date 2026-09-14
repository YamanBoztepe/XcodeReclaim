import AppKit
import SwiftUI
import Testing
import XcodeReclaimPresentation
import XcodeReclaimUI

@MainActor
struct LeftoverListViewDrawingTests {
    @Test("Every measured leftover is drawn with its size")
    func draws_everyLeftoverItWasGivenHoweverManyThereAre() throws {
        let manyMoreThanFitInAWindow = 60
        let oneSectionHeading = 1

        let table = try tableOf(makeSUT(holding: manyMoreThanFitInAWindow))

        #expect(table.numberOfRows == manyMoreThanFitInAWindow + oneSectionHeading)
    }

    @Test
    func draws_noMoreHeightThanAWindowCanGive() {
        let manyMoreThanFitInAWindow = 60
        let whatEveryScreenCanGive = 600.0

        let asked = whatTheScreenAsksFor(holding: manyMoreThanFitInAWindow)

        #expect(asked.height <= whatEveryScreenCanGive)
    }
}

private extension LeftoverListViewDrawingTests {
    func makeSUT(holding rows: Int) -> LeftoverListView {
        let section = LeftoverSection(
            id: "Caches and support files",
            name: "Caches and support files",
            symbol: "folder.fill",
            tint: .teal,
            size: "68.0 GB",
            share: 1,
            rows: (1...rows).map(row(numbered:)))

        return LeftoverListView(
            model: LeftoverListUIModel(title: "68.0 GB to reclaim", isMeasuring: false, sections: [section]),
            onAppear: {},
            onRefresh: {},
            onSelect: { _ in },
            onSort: { _ in },
            onAskAboutDeleting: { _ in },
            onConfirm: {},
            onBackOut: {})
    }

    func row(numbered place: Int) -> LeftoverRow {
        LeftoverRow(
            id: "Leftover \(place)",
            name: "Leftover \(place)",
            size: "\(place).0 KB",
            refusal: nil,
            holdsTheMostRoom: false,
            deletionUnderWay: nil,
            canBeDeleted: true)
    }

    func hosted(_ screen: LeftoverListView) -> NSHostingView<LeftoverListView> {
        let roomTheNamesNeed = 700.0
        let asTallAsAScreen = 800.0
        let shown = NSHostingView(rootView: screen)
        shown.frame = CGRect(x: 0, y: 0, width: roomTheNamesNeed, height: asTallAsAScreen)
        let window = NSWindow(contentRect: shown.frame, styleMask: [.titled], backing: .buffered, defer: false)
        window.contentView = shown
        shown.layoutSubtreeIfNeeded()
        settle()
        return shown
    }

    func tableOf(_ screen: LeftoverListView) throws -> NSTableView {
        try #require(everyTable(in: hosted(screen)).first, "the screen drew no table")
    }

    func whatTheScreenAsksFor(holding rows: Int) -> CGSize {
        hosted(makeSUT(holding: rows)).fittingSize
    }

    func everyTable(in view: NSView) -> [NSTableView] {
        (view as? NSTableView).map { [$0] } ?? view.subviews.flatMap(everyTable(in:))
    }

    func settle() {
        let turnsBeforeTheTableHasItsRows = 50

        for _ in 0..<turnsBeforeTheTableHasItsRows {
            RunLoop.current.run(mode: .default, before: .distantPast)
        }
    }
}
