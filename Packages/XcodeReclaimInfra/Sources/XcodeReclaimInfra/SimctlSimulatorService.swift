import Foundation
import XcodeReclaimEngine

public struct SimctlSimulatorService: SimulatorService {
    private let commandRunner: any CommandRunner

    public init(commandRunner: any CommandRunner) {
        self.commandRunner = commandRunner
    }

    public func simulators() throws -> [Simulator] {
        let listed = try commandRunner.run(executable: xcrun, arguments: ["simctl", "list", "devices", "-j"])
        let reported = try JSONDecoder().decode(ReportedDevices.self, from: Data(listed.utf8))

        return reported.devices.sorted { $0.key < $1.key }.flatMap { runtime, devices in
            devices.map { device in
                Simulator(
                    identifier: device.udid,
                    name: device.name,
                    runtime: SimulatorRuntimeIdentifier.name(of: runtime),
                    isShutDown: device.state == "Shutdown",
                    bytes: device.dataPathSize ?? 0)
            }
        }
    }

    public func delete(simulatorWithIdentifier identifier: String) throws {
        _ = try commandRunner.run(executable: xcrun, arguments: ["simctl", "delete", identifier])
    }
}

private struct ReportedDevices: Decodable {
    struct ReportedDevice: Decodable {
        let udid: String
        let name: String
        let state: String
        let dataPathSize: Int?
    }

    let devices: [String: [ReportedDevice]]
}

private extension SimctlSimulatorService {
    var xcrun: URL { URL(fileURLWithPath: "/usr/bin/xcrun") }
}
