import Foundation
import Testing
import XcodeReclaimEngine
import XcodeReclaimInfra

struct LocalArchiveLoaderTests {
    @Test("An archive is delivered with its name, its version, its build and when it was made")
    func load_deliversAnArchiveWithWhatItsRecordSays() {
        let roomItTakes = 385_875_968
        let archives = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(archives) }
        let archive = ArchiveOnDisk.made(
            named: "Communite Test 676",
            recording: ArchiveOnDisk.record(name: "Communite Test", version: "2.0.0", build: "676", created: sixteenthOfSeptember),
            onDay: "2026-09-16",
            inside: archives)
        let (sut, disk) = makeSUT(readingArchivesIn: archives)
        disk.lists(archive, onDay: "2026-09-16", inside: archives)
        disk.sizes[archive] = roomItTakes

        let received = sut.load()

        #expect(
            received == [
                Archive(path: archive, name: "Communite Test", version: "2.0.0", build: "676", created: sixteenthOfSeptember, bytes: roomItTakes)
            ])
    }

    @Test("An archive whose record cannot be read is delivered named by its folder")
    func load_namesAnArchiveWhoseRecordCannotBeReadByItsFolder() {
        let archives = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(archives) }
        let archive = ArchiveOnDisk.madeWithNoRecord(named: "Communite Test 676", onDay: "2026-09-16", inside: archives)
        let (sut, disk) = makeSUT(readingArchivesIn: archives)
        disk.lists(archive, onDay: "2026-09-16", inside: archives)

        let received = sut.load()

        #expect(received == [Archive(path: archive, name: "Communite Test 676", version: nil, build: nil, created: nil, bytes: 0)])
    }

    @Test
    func load_deliversNoVersionOrBuildForARecordThatCarriesNoApplication() {
        let archives = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(archives) }
        let archive = ArchiveOnDisk.made(named: "Communite Test 676", recording: ["Name": "Communite Test"], onDay: "2026-09-16", inside: archives)
        let (sut, disk) = makeSUT(readingArchivesIn: archives)
        disk.lists(archive, onDay: "2026-09-16", inside: archives)

        let received = sut.load()

        #expect(received == [Archive(path: archive, name: "Communite Test", version: nil, build: nil, created: nil, bytes: 0)])
    }

    @Test("Archives offer the archives they hold and nothing else")
    func load_offersTheArchivesADayHoldsAndNothingElse() {
        let archives = URL(filePath: "/developer/Xcode/Archives")
        let day = archives.appending(path: "2026-09-16")
        let archive = day.appending(path: "Communite Test 676.xcarchive")
        let (sut, disk) = makeSUT(readingArchivesIn: archives)
        disk.folders[archives] = [day]
        disk.folders[day] = [archive, day.appending(path: "Communite Test 676.xcarchive.notes"), day.appending(path: "Notes")]

        let received = sut.load()

        #expect(received.map(\.path) == [archive])
    }

    @Test
    func load_deliversTheArchivesOfEveryDay() {
        let archives = URL(filePath: "/developer/Xcode/Archives")
        let (sut, disk) = makeSUT(readingArchivesIn: archives)
        let first = disk.lists(named: "Communite Test 676", onDay: "2026-09-16", inside: archives)
        let second = disk.lists(named: "Communite Test 702", onDay: "2026-09-24", inside: archives)

        let received = sut.load()

        #expect(received.map(\.path) == [first, second])
    }

    @Test
    func load_deliversAnArchiveListedAsAFolderWithoutItsTrailingSlash() {
        let archives = URL(filePath: "/developer/Xcode/Archives")
        let day = archives.appending(path: "2026-09-16")
        let (sut, disk) = makeSUT(readingArchivesIn: archives)
        disk.folders[archives] = [day]
        disk.folders[day] = [URL(filePath: "/developer/Xcode/Archives/2026-09-16/Communite Test 676.xcarchive/", directoryHint: .isDirectory)]

        let received = sut.load()

        #expect(received.map { $0.path.path(percentEncoded: false) } == ["/developer/Xcode/Archives/2026-09-16/Communite Test 676.xcarchive"])
    }
}

private extension DiskStub {
    func lists(_ archive: URL, onDay day: String, inside archives: URL) {
        let dayFolder = archives.appending(path: day)
        folders[archives, default: []].append(dayFolder)
        folders[dayFolder, default: []].append(archive)
    }

    func lists(named name: String, onDay day: String, inside archives: URL) -> URL {
        let archive = archives.appending(path: day).appending(path: "\(name).xcarchive")
        lists(archive, onDay: day, inside: archives)
        return archive
    }
}

private extension LocalArchiveLoaderTests {
    var sixteenthOfSeptember: Date {
        let secondsFrom2001ToTheSixteenthOfSeptember = 811_264_966.0
        return Date(timeIntervalSinceReferenceDate: secondsFrom2001ToTheSixteenthOfSeptember)
    }

    func makeSUT(readingArchivesIn archives: URL) -> (sut: LocalArchiveLoader, disk: DiskStub) {
        let disk = DiskStub()
        let sut = LocalArchiveLoader(disk: disk, archivesFolder: archives)
        return (sut, disk)
    }
}
