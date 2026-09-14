import XcodeReclaim

@MainActor
func screenMeasuring(_ machine: MachineStub) -> LeftoverListContainerView {
    LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: machine.deleting)
}

@MainActor
func screenMeasuring(_ machine: SlowMachineStub) -> LeftoverListContainerView {
    LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: machine.deleting)
}

@MainActor
func screenMeasuring(_ machine: MachineThreadSpy) -> LeftoverListContainerView {
    LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: MachineStub().deleting)
}
