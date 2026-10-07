import Foundation
import Testing
import XcodeReclaimEngine
import XcodeReclaimInfra

struct SimctlRuntimeServiceTests {
    @Test
    func runtimes_asksTheToolForTheRuntimeListAsJSON() throws {
        let (sut, commandRunner) = makeSUT()
        commandRunner.answers["xcrun"] = .success(RuntimeList.reporting([]))

        _ = try sut.runtimes()

        #expect(commandRunner.runs == [.init(executable: xcrun, arguments: ["simctl", "runtime", "list", "-j"])])
    }

    @Test
    func runtimes_deliversEveryRuntimeTheListReports() throws {
        let (sut, commandRunner) = makeSUT()
        commandRunner.answers["xcrun"] = .success(
            RuntimeList.reporting([
                .init(identifier: "AAAA-1", version: "26.2", build: "23C54", sizeBytes: 10_407_690_816),
                .init(
                    identifier: "BBBB-2", runtimeIdentifier: "com.apple.CoreSimulator.SimRuntime.iOS-18-6", version: "18.6", build: "22G86",
                    sizeBytes: 8_838_255_185),
            ]))

        let received = try sut.runtimes()

        #expect(
            received == [
                Runtime(
                    identifier: "AAAA-1", name: "iOS 26.2", build: "23C54", simulatorRuntime: "iOS 26.2", lastUsed: lastUsed,
                    bytes: 10_407_690_816),
                Runtime(
                    identifier: "BBBB-2", name: "iOS 18.6", build: "22G86", simulatorRuntime: "iOS 18.6", lastUsed: lastUsed,
                    bytes: 8_838_255_185),
            ])
    }

    @Test(arguments: [
        ("com.apple.CoreSimulator.SimRuntime.iOS-26-4", "26.4.1", "iOS 26.4.1", "iOS 26.4"),
        ("com.apple.CoreSimulator.SimRuntime.watchOS-11-1", "11.1", "watchOS 11.1", "watchOS 11.1"),
        ("com.apple.CoreSimulator.SimRuntime.iOS", "26.2", "com.apple.CoreSimulator.SimRuntime.iOS", "com.apple.CoreSimulator.SimRuntime.iOS"),
        ("iOS-26-2", "26.2", "iOS-26-2", "iOS-26-2"),
    ])
    func runtimes_namesARuntimeByItsPlatformAndItsOwnVersionAndKeepsTheRuntimeItsSimulatorsSitOn(
        runtimeIdentifier: String, version: String, name: String, simulatorRuntime: String
    ) throws {
        let (sut, commandRunner) = makeSUT()
        commandRunner.answers["xcrun"] = .success(RuntimeList.reporting([.init(runtimeIdentifier: runtimeIdentifier, version: version)]))

        let received = try sut.runtimes()

        #expect(received.map(\.name) == [name])
        #expect(received.map(\.simulatorRuntime) == [simulatorRuntime])
    }

    @Test
    func runtimes_deliversARuntimeTheToolNeverUsedWithNoMomentItWasLastUsed() throws {
        let (sut, commandRunner) = makeSUT()
        commandRunner.answers["xcrun"] = .success(RuntimeList.reporting([.init(lastUsedAt: nil)]))

        let received = try sut.runtimes()

        #expect(received.map(\.lastUsed) == [nil])
    }

    @Test
    func runtimes_throwsWhenTheListCannotBeRead() {
        let (sut, commandRunner) = makeSUT()
        commandRunner.answers["xcrun"] = .success("not the list at all")

        #expect(throws: (any Error).self) { try sut.runtimes() }
    }

    @Test
    func runtimes_throwsWhenAMomentCannotBeRead() {
        let (sut, commandRunner) = makeSUT()
        commandRunner.answers["xcrun"] = .success(RuntimeList.reporting([.init(lastUsedAt: "yesterday")]))

        #expect(throws: (any Error).self) { try sut.runtimes() }
    }

    @Test
    func delete_tellsTheServiceToDeleteTheRuntime() throws {
        let runtimeIdentifier = "9A65D489-798D-4E19-8CBC-FA5C9A1F2A1E"
        let (sut, commandRunner) = makeSUT()

        try sut.delete(runtimeWithIdentifier: runtimeIdentifier)

        #expect(commandRunner.runs == [.init(executable: xcrun, arguments: ["simctl", "runtime", "delete", runtimeIdentifier])])
    }

    @Test("A simulator runtime the service refuses to delete frees nothing")
    func delete_throwsWhatTheServiceSaidWhenItRefuses() {
        let (sut, commandRunner) = makeSUT()
        commandRunner.answers["xcrun"] = .failure(WorldFailure(sentence: "Invalid runtime"))

        let received = #expect(throws: (any Error).self) { try sut.delete(runtimeWithIdentifier: "9A65D489") }

        #expect(received?.localizedDescription == "Invalid runtime")
    }
}

private extension SimctlRuntimeServiceTests {
    var xcrun: URL { URL(fileURLWithPath: "/usr/bin/xcrun") }
    var lastUsed: Date {
        let secondsFrom2001ToTheFirstOfOctober = 812_549_866.0
        return Date(timeIntervalSinceReferenceDate: secondsFrom2001ToTheFirstOfOctober)
    }

    func makeSUT() -> (sut: SimctlRuntimeService, commandRunner: CommandRunnerSpy) {
        let commandRunner = CommandRunnerSpy()
        let sut = SimctlRuntimeService(commandRunner: commandRunner)
        return (sut, commandRunner)
    }
}
