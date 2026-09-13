import Foundation

public struct WhereXcodeLeavesThings: Sendable {
    public let developerFolder: URL
    public let applicationsFolder: URL
    public let worthDeleting: Int

    public static let whatIsWorthDeleting = 100_000_000

    public static let onThisMachine = WhereXcodeLeavesThings(
        developerFolder: URL(filePath: NSHomeDirectory()).appending(path: "Library/Developer"),
        applicationsFolder: URL(filePath: "/Applications"),
        worthDeleting: whatIsWorthDeleting)
}
