import SwiftUI
import Testing
import XcodeReclaimPresentation
import XcodeReclaimUI

struct LeftoverListMenuTests {
    @Test
    func deletion_isDeleteImmediatelyOnOptionCommandDelete() {
        let sut = makeSUT()

        #expect(sut.deletion.title == "Delete Immediately…")
        #expect(sut.deletion.shortcut == KeyboardShortcut(.delete, modifiers: [.command, .option]))
    }

    @Test
    func refresh_isRefreshOnCommandR() {
        let sut = makeSUT()

        #expect(sut.refresh.title == "Refresh")
        #expect(sut.refresh.shortcut == KeyboardShortcut("r", modifiers: .command))
    }

    @Test(arguments: [true, false])
    func deletion_isOfferedWhenWhatIsChosenCanBeDeleted(canDeleteSelection: Bool) {
        let sut = makeSUT(showing: LeftoverListUIModel(title: "", isMeasuring: false, canDeleteSelection: canDeleteSelection))

        #expect(sut.deletion.isOffered == canDeleteSelection)
    }

    @Test(arguments: [true, false])
    func refresh_isOfferedWhenTheScreenIsNotMeasuring(isMeasuring: Bool) {
        let sut = makeSUT(showing: LeftoverListUIModel(title: "", isMeasuring: isMeasuring))

        #expect(sut.refresh.isOffered == !isMeasuring)
    }

    @Test
    func perform_asksAboutDeletingFromTheDeletionAndRefreshesFromTheRefresh() {
        var asked: [String] = []
        let sut = makeSUT(onRefresh: { asked.append("refresh") }, onAskAboutDeleting: { asked.append("ask about deleting") })

        sut.deletion.perform()
        sut.refresh.perform()

        #expect(asked == ["ask about deleting", "refresh"])
    }
}

private extension LeftoverListMenuTests {
    func makeSUT(
        showing model: LeftoverListUIModel = LeftoverListUIModel(title: "", isMeasuring: false),
        onRefresh: @escaping () -> Void = {},
        onAskAboutDeleting: @escaping () -> Void = {}
    ) -> LeftoverListMenu {
        LeftoverListMenu(model: model, onRefresh: onRefresh, onAskAboutDeleting: onAskAboutDeleting)
    }
}
