import Testing
import XcodeReclaim
import XcodeReclaimPresentation

@MainActor
struct LeftoverListUIComposerTests {
    @Test func screen_doesNotKeepItsViewModelAliveOnceTheScreenIsGone() {
        let machine = TheMachineSpy()
        var screen: LeftoverListContainerView? = LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: machine.deleting)
        weak let model = screen?.model

        screen = nil

        #expect(model == nil)
    }
}
