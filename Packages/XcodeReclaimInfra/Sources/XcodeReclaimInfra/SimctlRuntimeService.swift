import Foundation
import XcodeReclaimEngine

public struct SimctlRuntimeService: RuntimeService {
    private let commandRunner: any CommandRunner

    public init(commandRunner: any CommandRunner) {
        self.commandRunner = commandRunner
    }

    public func runtimes() throws -> [Runtime] {
        let listed = try commandRunner.run(executable: xcrun, arguments: ["simctl", "runtime", "list", "-j"])
        let reported = try JSONDecoder().decode([String: ReportedRuntime].self, from: Data(listed.utf8))

        return try reported.values.sorted { $0.identifier < $1.identifier }.map { runtime in
            Runtime(
                identifier: runtime.identifier,
                name: name(of: runtime),
                build: runtime.build,
                simulatorRuntime: SimulatorRuntimeIdentifier.name(of: runtime.runtimeIdentifier),
                lastUsed: try runtime.lastUsedAt.map(lastUsed(from:)),
                bytes: runtime.sizeBytes)
        }
    }

    public func delete(runtimeWithIdentifier identifier: String) throws {
        _ = try commandRunner.run(executable: xcrun, arguments: ["simctl", "runtime", "delete", identifier])
    }
}

private struct ReportedRuntime: Decodable {
    let identifier: String
    let runtimeIdentifier: String
    let version: String
    let build: String
    let sizeBytes: Int
    let lastUsedAt: String?
}

private extension SimctlRuntimeService {
    var xcrun: URL { URL(fileURLWithPath: "/usr/bin/xcrun") }

    func name(of runtime: ReportedRuntime) -> String {
        guard let read = SimulatorRuntimeIdentifier.platformAndVersion(of: runtime.runtimeIdentifier) else { return runtime.runtimeIdentifier }

        return "\(read.platform) \(runtime.version)"
    }

    func lastUsed(from written: String) throws -> Date {
        try Date(written, strategy: .iso8601)
    }
}
