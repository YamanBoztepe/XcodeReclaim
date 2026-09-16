import Foundation
import Testing
import XcodeReclaim

struct XcodeLocationsTests {
    @Test func onThisMachine_namesTheFoldersXcodeLeavesThingsIn() {
        let home = NSHomeDirectory()

        let places = XcodeLocations.onThisMachine

        #expect(places.developerFolder.path(percentEncoded: false) == "\(home)/Library/Developer")
        #expect(places.applicationsFolder.path(percentEncoded: false) == "/Applications")
    }

    @Test func onThisMachine_saysAHundredMegabytesIsWorthDeleting() {
        let aHundredMegabytes = 100_000_000

        #expect(XcodeLocations.onThisMachine.worthDeleting == aHundredMegabytes)
    }

    @Test func onThisMachine_namesAFolderEveryMacReallyHas() {
        let places = XcodeLocations.onThisMachine

        #expect(FileManager.default.fileExists(atPath: places.applicationsFolder.path(percentEncoded: false)))
    }
}
