import Foundation
import Testing
import XcodeReclaim

struct WhereXcodeLeavesThingsTests {
    @Test func onThisMachine_namesTheFoldersXcodeLeavesThingsIn() {
        let home = NSHomeDirectory()

        let places = WhereXcodeLeavesThings.onThisMachine

        #expect(places.developerFolder.path(percentEncoded: false) == "\(home)/Library/Developer")
        #expect(places.devicesFolder.path(percentEncoded: false) == "\(home)/Library/Developer/CoreSimulator/Devices")
        #expect(places.applicationsFolder.path(percentEncoded: false) == "/Applications")
    }

    @Test func onThisMachine_keepsTheDevicesInsideTheDeveloperFolder() {
        let places = WhereXcodeLeavesThings.onThisMachine

        #expect(places.devicesFolder.path(percentEncoded: false).hasPrefix("\(places.developerFolder.path(percentEncoded: false))/"))
    }

    @Test func onThisMachine_saysAHundredMegabytesIsWorthDeleting() {
        let aHundredMegabytes = 100_000_000

        #expect(WhereXcodeLeavesThings.onThisMachine.worthDeleting == aHundredMegabytes)
    }

    @Test func onThisMachine_namesFoldersTheDeveloperReallyHas() {
        let places = WhereXcodeLeavesThings.onThisMachine

        #expect(FileManager.default.fileExists(atPath: places.applicationsFolder.path(percentEncoded: false)))
        #expect(FileManager.default.fileExists(atPath: places.developerFolder.path(percentEncoded: false)))
    }
}
