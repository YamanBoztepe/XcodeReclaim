import Foundation
import Testing
import XcodeReclaimCore
import XcodeReclaimEngine

struct MeasureLeftoversRuntimeTests {
    @Test("A simulator runtime is delivered with its version, its build and the room it takes")
    func measure_deliversARuntimeWithItsVersionItsBuildAndTheRoomItTakes() {
        let roomItTakes = 10_407_690_816
        let runtimeIdentifier = "9A65D489-798D-4E19-8CBC-FA5C9A1F2A1E"
        let (sut, disk, runtimes, _) = makeSUT()
        runtimes.report = .success([runtime(identified: runtimeIdentifier, named: "iOS 26.2", build: "23C54", taking: roomItTakes)])

        let received = sut.leftovers(measuring: [.runtimes], announcing: disk.announce)

        #expect(
            received == [
                Leftover(kind: .runtime(name: "iOS 26.2", build: "23C54", lastUsed: nil), bytes: roomItTakes, place: .runtime(runtimeIdentifier))
            ])
    }

    @Test("A simulator runtime is delivered with when it was last used")
    func measure_deliversARuntimeWithWhenItWasLastUsed() {
        let secondsFrom2001ToTheFirstOfOctober = 812_549_866.0
        let lastUsed = Date(timeIntervalSinceReferenceDate: secondsFrom2001ToTheFirstOfOctober)
        let (sut, disk, runtimes, _) = makeSUT()
        runtimes.report = .success([runtime(lastUsed: lastUsed)])

        let received = sut.leftovers(measuring: [.runtimes], announcing: disk.announce)

        #expect(received.map(\.kind) == [.runtime(name: "iOS 26.2", build: "23C54", lastUsed: lastUsed)])
    }

    @Test("A simulator runtime never used is delivered as never used")
    func measure_deliversARuntimeNeverUsedAsNeverUsed() {
        let (sut, disk, runtimes, _) = makeSUT()
        runtimes.report = .success([runtime(lastUsed: nil)])

        let received = sut.leftovers(measuring: [.runtimes], announcing: disk.announce)

        #expect(received.map(\.kind) == [.runtime(name: "iOS 26.2", build: "23C54", lastUsed: nil)])
    }

    @Test("A simulator runtime a running simulator sits on is delivered as in use")
    func measure_deliversTheRuntimesARunningSimulatorSitsOnAsInUse() {
        let (sut, disk, runtimes, simulators) = makeSUT()
        runtimes.report = .success([
            runtime(named: "iOS 26.4", build: "23E244", servingSimulatorsOn: "iOS 26.4"),
            runtime(named: "iOS 26.4.1", build: "23E254a", servingSimulatorsOn: "iOS 26.4"),
            runtime(named: "iOS 26.2", build: "23C54", servingSimulatorsOn: "iOS 26.2"),
        ])
        simulators.report = .success([simulator(on: "iOS 26.4", isShutDown: false), simulator(on: "iOS 26.2", isShutDown: true)])

        let received = sut.leftovers(measuring: [.runtimes], announcing: disk.announce)

        #expect(received.map(\.refusal) == [.runtimeIsInUse, .runtimeIsInUse, nil])
    }

    @Test("A simulator runtime is delivered as not in use when the simulators cannot be listed")
    func measure_deliversARuntimeAsNotInUseWhenTheSimulatorsCannotBeListed() {
        let (sut, disk, runtimes, simulators) = makeSUT()
        runtimes.report = .success([runtime()])
        simulators.report = .failure(ServiceCannotList())

        let received = sut.leftovers(measuring: [.runtimes], announcing: disk.announce)

        #expect(received.map(\.refusal) == [nil])
    }

    @Test("The other leftovers are delivered even when the simulator runtimes cannot be listed")
    func measure_deliversTheOtherLeftoversWhenTheRuntimesCannotBeListed() {
        let roomItTakes = 200
        let (sut, disk, runtimes, _) = makeSUT()
        runtimes.report = .failure(ServiceCannotList())
        disk.sizes[DeveloperFolder.derivedData] = roomItTakes

        let received = sut.leftovers(measuring: [.derivedData, .runtimes], announcing: disk.announce)

        #expect(received == [Leftover(kind: .derivedData, bytes: roomItTakes, place: .folder(DeveloperFolder.derivedData))])
    }

    @Test
    func measure_deliversARuntimeWhereTheServiceKnowsIt() {
        let runtimeIdentifier = "9A65D489-798D-4E19-8CBC-FA5C9A1F2A1E"
        let (sut, disk, runtimes, _) = makeSUT()
        runtimes.report = .success([runtime(identified: runtimeIdentifier)])

        let received = sut.leftovers(measuring: [.runtimes], announcing: disk.announce)

        #expect(received.map(\.place) == [.runtime(runtimeIdentifier)])
    }

    @Test
    func measure_deliversEveryRuntimeTheServiceReportsWithItsOwnRoom() {
        let (sut, disk, runtimes, _) = makeSUT()
        runtimes.report = .success([runtime(named: "iOS 26.2", taking: 300), runtime(named: "iOS 18.6", taking: 200)])

        let received = sut.leftovers(measuring: [.runtimes], announcing: disk.announce)

        #expect(received.map(\.bytes) == [300, 200])
    }
}

private struct ServiceCannotList: Error {}

private extension MeasureLeftoversRuntimeTests {
    func makeSUT(worthDeleting: Int = 1) -> (sut: MeasureLeftovers, disk: WorldSpy, runtimes: RuntimeServiceSpy, simulators: SimulatorServiceSpy) {
        let disk = WorldSpy()
        let runtimes = RuntimeServiceSpy()
        let simulators = SimulatorServiceSpy()
        let sut = MeasureLeftovers(
            developerFolder: DeveloperFolder.root,
            cachesFolder: DeveloperFolder.caches,
            disk: disk,
            simulatorService: simulators,
            runtimeService: runtimes,
            xcodeCopyLoader: XcodeCopyLoaderStub(),
            archiveLoader: ArchiveLoaderStub(),
            toolchainLoader: ToolchainLoaderStub(),
            worthDeleting: worthDeleting)
        return (sut, disk, runtimes, simulators)
    }

    func runtime(
        identified identifier: String = "9A65D489-798D-4E19-8CBC-FA5C9A1F2A1E",
        named name: String = "iOS 26.2",
        build: String = "23C54",
        servingSimulatorsOn simulatorRuntime: String = "iOS 26.2",
        lastUsed: Date? = nil,
        taking bytes: Int = 200
    ) -> Runtime {
        Runtime(identifier: identifier, name: name, build: build, simulatorRuntime: simulatorRuntime, lastUsed: lastUsed, bytes: bytes)
    }

    func simulator(on runtime: String, isShutDown: Bool) -> Simulator {
        Simulator(identifier: "21B507D3-909E-465B-957C-4B370278399F", name: "iPhone 17", runtime: runtime, isShutDown: isShutDown, bytes: 0)
    }
}
