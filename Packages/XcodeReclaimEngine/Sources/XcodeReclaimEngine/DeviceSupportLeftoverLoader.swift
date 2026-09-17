import Foundation
import XcodeReclaimCore

struct DeviceSupportLeftoverLoader {
    let developerFolder: URL
    let disk: any MeasureLeftovers.Disk

    func leftovers(announcing announce: (String) -> Void) -> [Leftover] {
        let cost = "the symbols are put back the next time that device is plugged in"
        let deviceSupport = developerFolder.appending(path: "Xcode/iOS DeviceSupport")

        return disk.foldersInside(deviceSupport).map { version in
            let systemVersion = systemVersion(in: version.lastPathComponent)
            let name = "Device support (\(systemVersion.map { "iOS \($0)" } ?? version.lastPathComponent))"
            announce(name)

            return Leftover(
                kind: .deviceSupport(systemVersion: systemVersion),
                name: name,
                bytes: disk.bytesUsedByFolder(at: version),
                place: .folder(version),
                cost: cost)
        }
    }

    private func systemVersion(in folderName: String) -> String? {
        let modelVersionAndBuild = /^\S+ (\S+) \(\S+\)$/
        guard let read = try? modelVersionAndBuild.wholeMatch(in: folderName) else { return nil }

        return String(read.1)
    }
}
