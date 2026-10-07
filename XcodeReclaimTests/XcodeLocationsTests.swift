import Foundation
import Testing
import XcodeReclaim

struct XcodeLocationsTests {
    @Test func forUser_namesTheFoldersXcodeLeavesThingsIn() {
        let home = URL(filePath: "/Users/developer")

        let places = XcodeLocations.forUser(at: home)

        #expect(places.developerFolder.path(percentEncoded: false) == "/Users/developer/Library/Developer")
        #expect(places.applicationsFolder.path(percentEncoded: false) == "/Applications")
        #expect(places.archivesFolder.path(percentEncoded: false) == "/Users/developer/Library/Developer/Xcode/Archives")
        #expect(places.cachesFolder.path(percentEncoded: false) == "/Users/developer/Library/Caches")
        #expect(places.toolchainsFolder.path(percentEncoded: false) == "/Users/developer/Library/Developer/Toolchains")
    }

    @Test func forUser_saysAHundredMegabytesIsWorthDeleting() {
        let aHundredMegabytes = 100_000_000

        let places = XcodeLocations.forUser(at: anyHome)

        #expect(places.worthDeleting == aHundredMegabytes)
    }

    @Test func forUser_writesDaysInEnglishWhereTheDeveloperIs() {
        let places = XcodeLocations.forUser(at: anyHome)

        #expect(places.calendar.identifier == .gregorian)
        #expect(places.calendar.locale == Locale(identifier: "en_US_POSIX"))
        #expect(places.calendar.timeZone == .autoupdatingCurrent)
    }

    @Test func forUser_namesAFolderEveryMacReallyHas() {
        let places = XcodeLocations.forUser(at: anyHome)

        #expect(FileManager.default.fileExists(atPath: places.applicationsFolder.path(percentEncoded: false)))
    }
}

private extension XcodeLocationsTests {
    var anyHome: URL { URL(filePath: "/Users/developer") }
}
