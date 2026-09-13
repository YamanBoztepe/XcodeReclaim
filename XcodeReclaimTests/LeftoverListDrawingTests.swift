import AppKit
import Foundation
import SwiftUI
import Testing
import XcodeReclaim
import XcodeReclaimCore
import XcodeReclaimPresentation
import XcodeReclaimUI

@MainActor
final class LeftoverListDrawingTests {
    private var root: XcodeLeftovers?

    @Test func everyMeasuredLeftoverIsDrawnWithItsSize() {
        let few = 10
        let manyMoreThanFitInAWindow = 60

        let roomAFewTakeUp = whatTheListTakesUp(holding: few)
        let roomManyTakeUp = whatTheListTakesUp(holding: manyMoreThanFitInAWindow)

        #expect(roomManyTakeUp >= roomAFewTakeUp * 5)
    }

    @Test func theScreenAsksForNoMoreHeightThanAWindowCanGive() {
        let manyMoreThanFitInAWindow = 60

        let asked = whatTheScreenAsksFor(holding: manyMoreThanFitInAWindow)

        let whatEveryScreenCanGive = 600.0

        #expect(asked.height <= whatEveryScreenCanGive)
    }
}

private extension LeftoverListDrawingTests {
    func makeSUT(holding rows: Int) -> NSHostingView<LeftoverListView> {
        let machine = TheMachineSpy()
        let leftovers = XcodeLeftovers(measuring: machine.measuring, deleting: machine.deleting)
        root = leftovers
        let screen = leftovers.screen
        screen.model.open()
        machine.deliver((1...rows).map(leftover(numbered:)), from: 0)
        return NSHostingView(rootView: screen)
    }

    func leftover(numbered place: Int) -> Leftover {
        let aKilobyte = 1_000
        return Leftover(name: "Leftover \(place)", bytes: place * aKilobyte, place: .folder(URL(filePath: "/developer/\(place)")))
    }

    func whatTheListTakesUp(holding rows: Int) -> CGFloat {
        let hosting = laidOut(makeSUT(holding: rows), inAWindowTallEnoughFor: rows)
        return everyScrollView(in: hosting).first?.documentView?.frame.height ?? 0
    }

    func whatTheScreenAsksFor(holding rows: Int) -> CGSize {
        laidOut(makeSUT(holding: rows), inAWindowTallEnoughFor: rows).fittingSize
    }

    func laidOut(_ hosting: NSHostingView<LeftoverListView>, inAWindowTallEnoughFor rows: Int) -> NSHostingView<LeftoverListView> {
        let roomARowTakes = 60
        let roomTheNamesNeed = 700.0
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: roomTheNamesNeed, height: CGFloat(rows * roomARowTakes)),
            styleMask: [.titled],
            backing: .buffered,
            defer: false)
        window.contentView = hosting
        hosting.layoutSubtreeIfNeeded()
        window.displayIfNeeded()
        return hosting
    }

    func everyScrollView(in view: NSView) -> [NSScrollView] {
        (view as? NSScrollView).map { [$0] } ?? view.subviews.flatMap(everyScrollView(in:))
    }
}
