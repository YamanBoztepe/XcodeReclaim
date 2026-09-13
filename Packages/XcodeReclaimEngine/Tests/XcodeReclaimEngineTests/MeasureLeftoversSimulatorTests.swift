import Foundation
import Testing
import XcodeReclaimCore
import XcodeReclaimEngine

struct MeasureLeftoversSimulatorTests {
    @Test("A simulator is delivered among the folders")
    func measure_deliversASimulatorAmongTheFolders() {
        let (sut, disk, simulators) = makeSUT()
        disk.sizes[DeveloperFolder.derivedData] = 50
        simulators.report = .success([simulator(taking: 200)])

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["iPhone 17 (iOS 26.4, 21B507D3)", "Derived data"])
    }

    @Test("A simulator is named with the runtime it belongs to")
    func measure_namesASimulatorWithTheRuntimeItBelongsTo() {
        let (sut, disk, simulators) = makeSUT()
        simulators.report = .success([simulator(named: "iPhone 17", on: "iOS 26.4", identified: "21B507D3-909E-465B-957C-4B370278399F")])

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["iPhone 17 (iOS 26.4, 21B507D3)"])
    }

    @Test("A simulator is named with the start of its device identifier")
    func measure_namesASimulatorWithTheStartOfItsDeviceIdentifier() {
        let (sut, disk, simulators) = makeSUT()
        simulators.report = .success([simulator(named: "iPhone 16 Pro", on: "iOS 18.1", identified: "21B507D3-909E-465B-957C-4B370278399F")])

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["iPhone 16 Pro (iOS 18.1, 21B507D3)"])
    }

    @Test("A running simulator is delivered as running")
    func measure_deliversARunningSimulatorAsRunning() {
        let (sut, disk, simulators) = makeSUT()
        simulators.report = .success([simulator(isShutDown: false)])

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.refusal) == [.theSimulatorIsRunning])
    }

    @Test("A shut-down simulator is delivered as not running")
    func measure_deliversAShutDownSimulatorAsNotRunning() {
        let (sut, disk, simulators) = makeSUT()
        simulators.report = .success([simulator(isShutDown: true)])

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.refusal) == [nil])
    }

    @Test("A simulator carries what deleting it costs")
    func measure_deliversASimulatorWithWhatDeletingItCosts() {
        let (sut, disk, simulators) = makeSUT()
        simulators.report = .success([simulator(isShutDown: true)])

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.cost) == ["the apps inside it and their data are gone"])
    }

    @Test
    func measure_deliversASimulatorWhereTheServiceKnowsIt() {
        let deviceIdentifier = "21B507D3-909E-465B-957C-4B370278399F"
        let (sut, disk, simulators) = makeSUT()
        simulators.report = .success([simulator(identified: deviceIdentifier)])

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.place) == [.simulator(deviceIdentifier)])
    }
}

private extension MeasureLeftoversSimulatorTests {
    func makeSUT(worthDeleting: Int = 1) -> (sut: MeasureLeftovers, disk: DiskSpy, simulators: SimulatorServiceSpy) {
        let disk = DiskSpy()
        let simulators = SimulatorServiceSpy()
        let sut = MeasureLeftovers(
            developerFolder: DeveloperFolder.root,
            disk: disk,
            simulatorService: simulators,
            xcodeCopies: XcodeCopiesStub(),
            worthDeleting: worthDeleting)
        return (sut, disk, simulators)
    }

    func simulator(
        named name: String = "iPhone 17",
        on runtime: String = "iOS 26.4",
        identified identifier: String = "21B507D3-909E-465B-957C-4B370278399F",
        isShutDown: Bool = true,
        taking bytes: Int = 200
    ) -> Simulator {
        Simulator(identifier: identifier, name: name, runtime: runtime, isShutDown: isShutDown, bytes: bytes)
    }
}
