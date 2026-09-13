import Foundation
import XcodeReclaimCore

struct DeviceSupportVersions {
    let developerFolder: URL
    let disk: any Disk

    func leftovers(announcing announce: (String) -> Void) -> [Leftover] {
        let cost = "the symbols are put back the next time that device is plugged in"
        let deviceSupport = developerFolder.appending(path: "Xcode/iOS DeviceSupport")

        return disk.foldersInside(deviceSupport).map { version in
            let name = "Device support (\(systemVersion(in: version.lastPathComponent)))"
            announce(name)

            return Leftover(name: name, bytes: disk.bytesUsedByFolder(at: version), place: .folder(version), cost: cost)
        }
    }

    private func systemVersion(in folderName: String) -> String {
        let modelVersionAndBuild = /^\S+ (\S+) \(\S+\)$/
        guard let read = try? modelVersionAndBuild.wholeMatch(in: folderName) else { return folderName }

        return "iOS \(read.1)"
    }
}
