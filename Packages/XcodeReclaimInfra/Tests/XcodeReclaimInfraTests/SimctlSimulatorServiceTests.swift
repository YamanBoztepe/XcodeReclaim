import Foundation
import Testing
import XcodeReclaimEngine
import XcodeReclaimInfra

struct SimctlSimulatorServiceTests {
    @Test
    func simulators_deliversEveryDeviceTheListReports() throws {
        let (sut, tool) = makeSUT()
        tool.answers["xcrun"] = .success(
            SimulatorList.reporting([
                "com.apple.CoreSimulator.SimRuntime.iOS-18-1": [.init(udid: "AAAA-1", name: "iPhone 16 Pro")],
                "com.apple.CoreSimulator.SimRuntime.iOS-26-4": [.init(udid: "BBBB-2", name: "iPhone 17"), .init(udid: "CCCC-3", name: "iPad Pro")],
            ]))

        let received = try sut.simulators()

        #expect(received.map(\.identifier) == ["AAAA-1", "BBBB-2", "CCCC-3"])
        #expect(received.map(\.name) == ["iPhone 16 Pro", "iPhone 17", "iPad Pro"])
    }

    @Test(arguments: [("Shutdown", true), ("Booted", false), ("Booting", false), ("Shutting Down", false), ("Creating", false), ("shutdown", false)])
    func simulators_readsAnyStateOtherThanShutdownAsNotShutDown(state: String, isShutDown: Bool) throws {
        let (sut, tool) = makeSUT()
        tool.answers["xcrun"] = .success(SimulatorList.reporting(["com.apple.CoreSimulator.SimRuntime.iOS-26-4": [.init(state: state)]]))

        let received = try sut.simulators()

        #expect(received.map(\.isShutDown) == [isShutDown])
    }

    @Test(arguments: [
        ("com.apple.CoreSimulator.SimRuntime.iOS-26-4", "iOS 26.4"),
        ("com.apple.CoreSimulator.SimRuntime.watchOS-11-1", "watchOS 11.1"),
        ("com.apple.CoreSimulator.SimRuntime.iOS-15-0", "iOS 15.0"),
        ("com.apple.CoreSimulator.SimRuntime.iOS", "com.apple.CoreSimulator.SimRuntime.iOS"),
        ("com.apple.CoreSimulator.SimRuntime.iOS-26-4-extra", "com.apple.CoreSimulator.SimRuntime.iOS-26-4-extra"),
        ("iOS-26-4", "iOS-26-4"),
        ("com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro", "com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro"),
    ])
    func simulators_deliversADeviceWithTheRuntimeItSitsUnder(runtime: String, named: String) throws {
        let (sut, tool) = makeSUT()
        tool.answers["xcrun"] = .success(SimulatorList.reporting([runtime: [.init()]]))

        let received = try sut.simulators()

        #expect(received.map(\.runtime) == [named])
    }

    @Test
    func simulators_deliversADeviceWithTheRoomTheToolSaidItTakes() throws {
        let roomItTakes = 4_557_963_264
        let (sut, tool) = makeSUT()
        tool.answers["xcrun"] = .success(
            SimulatorList.reporting(["com.apple.CoreSimulator.SimRuntime.iOS-26-4": [.init(dataPathSize: roomItTakes)]]))

        let received = try sut.simulators()

        #expect(received.map(\.bytes) == [roomItTakes])
    }

    @Test
    func simulators_deliversEachDeviceWithItsOwnRoom() throws {
        let roomTheFirstTakes = 4_557_963_264
        let roomTheSecondTakes = 17_500_000
        let (sut, tool) = makeSUT()
        tool.answers["xcrun"] = .success(
            SimulatorList.reporting([
                "com.apple.CoreSimulator.SimRuntime.iOS-26-4": [
                    .init(udid: "AAAA-1", dataPathSize: roomTheFirstTakes),
                    .init(udid: "AAAA-2", dataPathSize: roomTheSecondTakes),
                ]
            ]))

        let received = try sut.simulators()

        #expect(received.map(\.bytes) == [roomTheFirstTakes, roomTheSecondTakes])
    }

    @Test
    func simulators_deliversADeviceWithNoReportedRoomAsTakingNone() throws {
        let (sut, tool) = makeSUT()
        tool.answers["xcrun"] = .success(
            SimulatorList.reporting(["com.apple.CoreSimulator.SimRuntime.iOS-26-4": [.init(dataPathSize: nil)]]))

        let received = try sut.simulators()

        #expect(received.map(\.bytes) == [0])
    }

    @Test
    func delete_tellsTheServiceToRemoveTheDevice() throws {
        let deviceIdentifier = "21B507D3-909E-465B-957C-4B370278399F"
        let (sut, tool) = makeSUT()

        try sut.delete(simulatorWithIdentifier: deviceIdentifier)

        #expect(tool.runs == [.init(executable: URL(fileURLWithPath: "/usr/bin/xcrun"), arguments: ["simctl", "delete", deviceIdentifier])])
    }

    @Test("A deletion the service refuses frees nothing")
    func delete_throwsWhatTheServiceSaidWhenItRefuses() {
        let (sut, tool) = makeSUT()
        tool.answers["xcrun"] = .failure(WorldFailure(sentence: "Invalid device"))

        let received = #expect(throws: (any Error).self) { try sut.delete(simulatorWithIdentifier: "21B507D3") }

        #expect(received?.localizedDescription == "Invalid device")
    }

    @Test
    func simulators_throwsWhenTheListCannotBeRead() {
        let (sut, tool) = makeSUT()
        tool.answers["xcrun"] = .success("not the list at all")

        #expect(throws: (any Error).self) { try sut.simulators() }
    }
}

private extension SimctlSimulatorServiceTests {
    func makeSUT() -> (sut: SimctlSimulatorService, tool: ToolSpy) {
        let tool = ToolSpy()
        let sut = SimctlSimulatorService(tool: tool)
        return (sut, tool)
    }
}
