import Foundation
import Testing
import XcodeReclaimEngine
import XcodeReclaimInfra

struct FileManagerDiskTests {
    @Test func aFolderCountsAFileWithMoreThanOnePathOnce() {
        let sut = makeSUT()
        let folder = makeFolder(holding: 1)
        defer { throwAway(folder) }
        AFolderOnTheDisk.putASecondPathTo("block 0", named: "the same block again", inside: folder)

        let received = sut.bytesUsedByFolder(at: folder)

        #expect(received == AFolderOnTheDisk.oneBlock)
    }

    @Test func aLeftoverWhoseFolderCannotBeFullyReadIsDeliveredWithWhatCouldBeRead() {
        let sut = makeSUT()
        let folder = makeFolder(holding: 1)
        defer { throwAway(folder) }
        let hidden = AFolderOnTheDisk.putAFolder(named: "unreadable", inside: folder)
        AFolderOnTheDisk.put(1, named: "block out of reach", inside: hidden)
        AFolderOnTheDisk.makeUnreadable(hidden)

        let received = sut.bytesUsedByFolder(at: folder)

        #expect(received == AFolderOnTheDisk.oneBlock)
    }

    @Test func aFolderCountsWhatItsSubfoldersHold() {
        let sut = makeSUT()
        let folder = makeFolder(holding: 1)
        defer { throwAway(folder) }
        let deeper = AFolderOnTheDisk.putAFolder(named: "deeper", inside: folder)
        AFolderOnTheDisk.put(1, named: "a block further down", inside: deeper)

        let received = sut.bytesUsedByFolder(at: folder)

        #expect(received == AFolderOnTheDisk.oneBlock * 2)
    }

    @Test func aFolderTakesTheRoomItsFilesOccupyRatherThanTheirLengths() {
        let sut = makeSUT()
        let folder = makeFolder(holding: 0)
        defer { throwAway(folder) }
        AFolderOnTheDisk.putAFileOf(1, named: "one byte", inside: folder)

        let received = sut.bytesUsedByFolder(at: folder)

        #expect(received == AFolderOnTheDisk.oneBlock)
    }

    @Test func aFolderThatIsNotThereTakesNoRoom() {
        let sut = makeSUT()
        let folder = makeFolder(holding: 1)
        throwAway(folder)

        let received = sut.bytesUsedByFolder(at: folder)

        #expect(received == 0)
    }

    @Test func aFolderThatIsNotThereHoldsNoFolders() {
        let sut = makeSUT()
        let folder = makeFolder(holding: 0)
        throwAway(folder)

        let received = sut.foldersInside(folder)

        #expect(received.isEmpty)
    }

    @Test func aFolderThatCannotBeReadHoldsNoFolders() {
        let sut = makeSUT()
        let folder = makeFolder(holding: 0)
        defer { throwAway(folder) }
        _ = AFolderOnTheDisk.putAFolder(named: "iPhone15,2 26.4 (22A1)", inside: folder)
        AFolderOnTheDisk.makeUnreadable(folder)

        let received = sut.foldersInside(folder)

        #expect(received.isEmpty)
    }

    @Test func deviceSupportOffersTheFoldersItHoldsAndNothingElse() {
        let sut = makeSUT()
        let deviceSupport = makeFolder(holding: 0)
        defer { throwAway(deviceSupport) }
        _ = AFolderOnTheDisk.putAFolder(named: "iPhone15,2 26.4 (22A1)", inside: deviceSupport)
        AFolderOnTheDisk.put(1, named: "a file sitting beside them", inside: deviceSupport)

        let received = sut.foldersInside(deviceSupport)

        #expect(received.map(\.lastPathComponent) == ["iPhone15,2 26.4 (22A1)"])
    }

    @Test func aRemovedFolderIsGoneFromTheDisk() throws {
        let sut = makeSUT()
        let folder = makeFolder(holding: 1)
        defer { throwAway(folder) }
        let held = AFolderOnTheDisk.putAFolder(named: "held", inside: folder)

        try sut.removeItem(at: held)

        #expect(sut.foldersInside(folder).isEmpty)
    }

    @Test func removingSomethingThatIsNotThereIsNotAFailure() {
        let sut = makeSUT()
        let folder = makeFolder(holding: 0)
        defer { throwAway(folder) }

        #expect(throws: Never.self) { try sut.removeItem(at: folder.appending(path: "never made")) }
    }

    @Test func aFolderThatCouldNotBeDeletedSaysWhatTheDiskSaid() {
        let sut = makeSUT()
        let folder = makeFolder(holding: 0)
        defer { throwAway(folder) }
        let held = AFolderOnTheDisk.putAFolder(named: "cache", inside: folder)
        AFolderOnTheDisk.makeUnwritable(folder)

        let received = #expect(throws: CocoaError.self) { try sut.removeItem(at: held) }

        #expect(received?.code == .fileWriteNoPermission)
        #expect(received?.localizedDescription.contains("cache") == true)
    }
}

private extension FileManagerDiskTests {
    func makeSUT() -> FileManagerDisk {
        FileManagerDisk()
    }

    func makeFolder(holding blocks: Int) -> URL {
        let folder = AFolderOnTheDisk.made()
        for block in 0..<blocks {
            AFolderOnTheDisk.put(1, named: "block \(block)", inside: folder)
        }
        return folder
    }

    func throwAway(_ folder: URL) {
        AFolderOnTheDisk.throwAway(folder)
    }
}
