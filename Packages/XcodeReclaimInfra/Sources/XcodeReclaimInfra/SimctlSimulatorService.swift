import Foundation
import XcodeReclaimEngine

public struct SimctlSimulatorService: SimulatorService {
    private let tool: any Tool

    public init(tool: any Tool) {
        self.tool = tool
    }

    public func simulators() throws -> [Simulator] {
        let listed = try tool.run(executable: xcrun, arguments: ["simctl", "list", "devices", "-j"])
        let reported = try JSONDecoder().decode(ReportedDevices.self, from: Data(listed.utf8))

        return reported.devices.sorted { $0.key < $1.key }.flatMap { runtime, devices in
            devices.map { device in
                Simulator(
                    identifier: device.udid,
                    name: device.name,
                    runtime: runtimeNamed(runtime),
                    isShutDown: device.state == "Shutdown",
                    bytes: device.dataPathSize ?? 0)
            }
        }
    }

    public func delete(simulatorWithIdentifier identifier: String) throws {
        _ = try tool.run(executable: xcrun, arguments: ["simctl", "delete", identifier])
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

    func runtimeNamed(_ identifier: String) -> String {
        let platformAndVersion = /^com\.apple\.CoreSimulator\.SimRuntime\.([A-Za-z]+)((?:-\d+)+)$/
        guard let read = try? platformAndVersion.wholeMatch(in: identifier) else { return identifier }

        return "\(read.1) \(read.2.dropFirst().split(separator: "-").joined(separator: "."))"
    }
}
