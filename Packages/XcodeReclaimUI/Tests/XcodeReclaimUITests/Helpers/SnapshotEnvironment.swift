import Foundation
import Testing

enum SnapshotEnvironment {
    static let recordedOnMacOS = 26

    static func isTheRecordingMachine(sourceLocation: SourceLocation) -> Bool {
        let running = ProcessInfo.processInfo.operatingSystemVersion
        guard running.majorVersion == recordedOnMacOS else {
            Issue.record(
                "Snapshots were recorded on macOS \(recordedOnMacOS) and this is macOS \(running.majorVersion).\(running.minorVersion).",
                sourceLocation: sourceLocation)
            return false
        }

        return true
    }
}
