import Foundation

public struct XcodeLocations: Sendable {
    public let developerFolder: URL
    public let applicationsFolder: URL
    public let worthDeleting: Int

    private static let whatIsWorthDeleting = 100_000_000

    public static func forUser(at home: URL) -> XcodeLocations {
        XcodeLocations(
            developerFolder: home.appending(path: "Library/Developer"),
            applicationsFolder: URL(filePath: "/Applications"),
            worthDeleting: whatIsWorthDeleting)
    }
}
