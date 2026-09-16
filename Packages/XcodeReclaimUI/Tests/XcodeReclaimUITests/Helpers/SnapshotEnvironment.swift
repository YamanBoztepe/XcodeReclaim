import Foundation
import Testing

enum SnapshotEnvironment {
    private static let recordedMajorVersion = 26
    private static let recordedMinorVersion = 6
    private static let recordedPatchVersion = 2
    static let recordedOnMacOS = OperatingSystemVersion(
        majorVersion: recordedMajorVersion, minorVersion: recordedMinorVersion, patchVersion: recordedPatchVersion)

    static func isTheRecordingMachine(sourceLocation: SourceLocation) -> Bool {
        let running = ProcessInfo.processInfo.operatingSystemVersion
        guard running.majorVersion == recordedOnMacOS.majorVersion,
            running.minorVersion == recordedOnMacOS.minorVersion,
            running.patchVersion == recordedOnMacOS.patchVersion
        else {
            Issue.record(
                "Snapshots were recorded on macOS \(written(recordedOnMacOS)) and this is macOS \(written(running)).",
                sourceLocation: sourceLocation)
            return false
        }

        return true
    }

    private static func written(_ version: OperatingSystemVersion) -> String {
        "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }
}
