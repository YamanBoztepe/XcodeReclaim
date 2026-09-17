import Foundation
import XcodeReclaimCore

struct DeviceSupportLeftoverLoader {
    let developerFolder: URL
    let disk: any MeasureLeftovers.Disk

    func leftovers(announcing announce: (Leftover.Kind, Leftover.Place) -> Void) -> [Leftover] {
        let deviceSupport = developerFolder.appending(path: "Xcode/iOS DeviceSupport")

        return disk.foldersInside(deviceSupport).map { version in
            let kind = Leftover.Kind.deviceSupport(systemVersion: systemVersion(in: version.lastPathComponent))
            announce(kind, .folder(version))

            return Leftover(kind: kind, bytes: disk.bytesUsedByFolder(at: version), place: .folder(version))
        }
    }

    private func systemVersion(in folderName: String) -> String? {
        let modelVersionAndBuild = /^\S+ (\S+) \(\S+\)$/
        guard let read = try? modelVersionAndBuild.wholeMatch(in: folderName) else { return nil }

        return String(read.1)
    }
}
