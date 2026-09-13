import Foundation
import Testing

enum SnapshotEnvironment {
    static let theMacOSTheseWereRecordedOn = 26

    static func isTheMachineTheseWereRecordedOn(sourceLocation: SourceLocation) -> Bool {
        let running = ProcessInfo.processInfo.operatingSystemVersion
        guard running.majorVersion == theMacOSTheseWereRecordedOn else {
            Issue.record(
                "Snapshots were recorded on macOS \(theMacOSTheseWereRecordedOn) and this is macOS \(running.majorVersion).\(running.minorVersion).",
                sourceLocation: sourceLocation)
            return false
        }

        return true
    }
}
