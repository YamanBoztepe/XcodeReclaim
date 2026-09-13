import Foundation

struct WhereXcodeLeavesThings: Sendable {
    let developerFolder: URL
    let devicesFolder: URL
    let applicationsFolder: URL
    let worthDeleting: Int

    static let whatIsWorthDeleting = 100_000_000

    static let onThisMachine = WhereXcodeLeavesThings(
        developerFolder: URL(filePath: NSHomeDirectory()).appending(path: "Library/Developer"),
        devicesFolder: URL(filePath: NSHomeDirectory()).appending(path: "Library/Developer/CoreSimulator/Devices"),
        applicationsFolder: URL(filePath: "/Applications"),
        worthDeleting: whatIsWorthDeleting)
}
