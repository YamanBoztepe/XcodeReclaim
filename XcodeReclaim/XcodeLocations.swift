import Foundation

public struct XcodeLocations: Sendable {
    public let developerFolder: URL
    public let applicationsFolder: URL
    public let archivesFolder: URL
    public let cachesFolder: URL
    public let toolchainsFolder: URL
    public let worthDeleting: Int
    public let calendar: Calendar

    private static let whatIsWorthDeleting = 100_000_000

    public static func forUser(at home: URL) -> XcodeLocations {
        XcodeLocations(
            developerFolder: home.appending(path: "Library/Developer"),
            applicationsFolder: URL(filePath: "/Applications"),
            archivesFolder: home.appending(path: "Library/Developer/Xcode/Archives"),
            cachesFolder: home.appending(path: "Library/Caches"),
            toolchainsFolder: home.appending(path: "Library/Developer/Toolchains"),
            worthDeleting: whatIsWorthDeleting,
            calendar: daysWrittenInEnglishWhereTheDeveloperIs)
    }

    private static var daysWrittenInEnglishWhereTheDeveloperIs: Calendar {
        var days = Calendar(identifier: .gregorian)
        days.locale = Locale(identifier: "en_US_POSIX")
        days.timeZone = .autoupdatingCurrent
        return days
    }
}
