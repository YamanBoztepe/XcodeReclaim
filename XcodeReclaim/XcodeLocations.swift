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
        let developer = home.appending(path: "Library/Developer")

        return XcodeLocations(
            developerFolder: developer,
            applicationsFolder: URL(filePath: "/Applications"),
            archivesFolder: developer.appending(path: "Xcode/Archives"),
            cachesFolder: home.appending(path: "Library/Caches"),
            toolchainsFolder: developer.appending(path: "Toolchains"),
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
