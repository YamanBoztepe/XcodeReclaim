import AppKit
import SwiftUI
import Testing
import XcodeReclaimPresentation
import XcodeReclaimUI

@MainActor
struct LeftoverListViewDrawingTests {
    @Test("Every measured leftover is drawn with its size")
    func draws_everyLeftoverItWasGivenHoweverManyThereAre() {
        let few = 10
        let manyMoreThanFitInAWindow = 60

        let roomAFewTakeUp = whatTheListTakesUp(holding: few)
        let roomManyTakeUp = whatTheListTakesUp(holding: manyMoreThanFitInAWindow)

        #expect(roomManyTakeUp >= roomAFewTakeUp * 5)
    }

    @Test func draws_noMoreHeightThanAWindowCanGive() {
        let manyMoreThanFitInAWindow = 60
        let whatEveryScreenCanGive = 600.0

        let asked = whatTheScreenAsksFor(holding: manyMoreThanFitInAWindow)

        #expect(asked.height <= whatEveryScreenCanGive)
    }
}

private extension LeftoverListViewDrawingTests {
    func makeSUT(holding rows: Int) -> NSHostingView<LeftoverListView> {
        let section = LeftoverSection(
            id: "Caches and support files",
            name: "Caches and support files",
            symbol: "folder.fill",
            tint: .teal,
            size: "68.0 GB",
            share: 1,
            rows: (1...rows).map(row(numbered:)))
        let screen = LeftoverListView(
            model: LeftoverListUIModel(title: "68.0 GB to reclaim", isMeasuring: false, sections: [section]),
            onAppear: {},
            onRefresh: {},
            onAskAboutDeleting: { _ in },
            onConfirm: {},
            onBackOut: {})
        return NSHostingView(rootView: screen)
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

    func whatTheListTakesUp(holding rows: Int) -> CGFloat {
        let shown = laidOut(makeSUT(holding: rows), inAWindowTallEnoughFor: rows)
        return everyScrollView(in: shown).first?.documentView?.frame.height ?? 0
    }

    func whatTheScreenAsksFor(holding rows: Int) -> CGSize {
        laidOut(makeSUT(holding: rows), inAWindowTallEnoughFor: rows).fittingSize
    }

    func laidOut(_ shown: NSHostingView<LeftoverListView>, inAWindowTallEnoughFor rows: Int) -> NSHostingView<LeftoverListView> {
        let roomARowTakes = 60
        let roomTheNamesNeed = 700.0
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: roomTheNamesNeed, height: CGFloat(rows * roomARowTakes)),
            styleMask: [.titled],
            backing: .buffered,
            defer: false)
        window.contentView = shown
        shown.layoutSubtreeIfNeeded()
        window.displayIfNeeded()
        return shown
    }

    func everyScrollView(in view: NSView) -> [NSScrollView] {
        (view as? NSScrollView).map { [$0] } ?? view.subviews.flatMap(everyScrollView(in:))
    }
}
