enum SimulatorRuntimeIdentifier {
    static func platformAndVersion(of identifier: String) -> (platform: String, version: String)? {
        let platformAndVersion = /^com\.apple\.CoreSimulator\.SimRuntime\.([A-Za-z]+)((?:-\d+)+)$/
        guard let read = try? platformAndVersion.wholeMatch(in: identifier) else { return nil }

        return (platform: String(read.1), version: read.2.dropFirst().split(separator: "-").joined(separator: "."))
    }

    static func name(of identifier: String) -> String {
        guard let read = platformAndVersion(of: identifier) else { return identifier }

        return "\(read.platform) \(read.version)"
    }
}
