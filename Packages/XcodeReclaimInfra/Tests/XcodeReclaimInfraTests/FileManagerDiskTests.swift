import Foundation
import Testing
import XcodeReclaimEngine
import XcodeReclaimInfra

struct FileManagerDiskTests {
    @Test("A folder counts a file with more than one path once")
    func bytesUsed_countsAFileWithMoreThanOnePathOnce() {
        let sut = makeSUT()
        let folder = makeFolder(holding: 1)
        defer { throwAway(folder) }
        FolderOnDisk.putASecondPathTo("block 0", named: "the same block again", inside: folder)

        let received = sut.bytesUsedByFolder(at: folder)

        #expect(received == FolderOnDisk.oneBlock)
    }

    @Test("A leftover whose folder cannot be fully read is delivered with what could be read")
    func bytesUsed_countsWhatCouldBeReadWhenPartOfTheFolderCannotBe() {
        let sut = makeSUT()
        let folder = makeFolder(holding: 1)
        defer { throwAway(folder) }
        let hidden = FolderOnDisk.putAFolder(named: "unreadable", inside: folder)
        FolderOnDisk.put(blocks: 1, named: "block out of reach", inside: hidden)
        FolderOnDisk.makeUnreadable(hidden)

        let received = sut.bytesUsedByFolder(at: folder)

        #expect(received == FolderOnDisk.oneBlock)
    }

    @Test
    func bytesUsed_countsWhatTheSubfoldersHold() {
        let sut = makeSUT()
        let folder = makeFolder(holding: 1)
        defer { throwAway(folder) }
        let deeper = FolderOnDisk.putAFolder(named: "deeper", inside: folder)
        FolderOnDisk.put(blocks: 1, named: "a block further down", inside: deeper)

        let received = sut.bytesUsedByFolder(at: folder)

        #expect(received == FolderOnDisk.oneBlock * 2)
    }

    @Test
    func bytesUsed_countsTheRoomAFileOccupiesRatherThanItsLength() {
        let sut = makeSUT()
        let folder = makeFolder(holding: 0)
        defer { throwAway(folder) }
        FolderOnDisk.put(bytes: 1, named: "one byte", inside: folder)

        let received = sut.bytesUsedByFolder(at: folder)

        #expect(received == FolderOnDisk.oneBlock)
    }

    @Test
    func bytesUsed_countsNothingForAFolderThatIsNotThere() {
        let sut = makeSUT()
        let folder = makeFolder(holding: 1)
        throwAway(folder)

        let received = sut.bytesUsedByFolder(at: folder)

        #expect(received == 0)
    }

    @Test
    func foldersInside_holdsNoneForAFolderThatIsNotThere() {
        let sut = makeSUT()
        let folder = makeFolder(holding: 0)
        throwAway(folder)

        let received = sut.foldersInside(folder)

        #expect(received.isEmpty)
    }

    @Test
    func foldersInside_holdsNoneForAFolderThatCannotBeRead() {
        let sut = makeSUT()
        let folder = makeFolder(holding: 0)
        defer { throwAway(folder) }
        _ = FolderOnDisk.putAFolder(named: "iPhone15,2 26.4 (22A1)", inside: folder)
        FolderOnDisk.makeUnreadable(folder)

        let received = sut.foldersInside(folder)

        #expect(received.isEmpty)
    }

    @Test("Device support offers the folders it holds and nothing else")
    func foldersInside_offersTheFoldersItHoldsAndNothingElse() {
        let sut = makeSUT()
        let deviceSupport = makeFolder(holding: 0)
        defer { throwAway(deviceSupport) }
        _ = FolderOnDisk.putAFolder(named: "iPhone15,2 26.4 (22A1)", inside: deviceSupport)
        FolderOnDisk.put(blocks: 1, named: "a file sitting beside them", inside: deviceSupport)

        let received = sut.foldersInside(deviceSupport)

        #expect(received.map(\.lastPathComponent) == ["iPhone15,2 26.4 (22A1)"])
    }

    @Test
    func removeItem_takesTheFolderOffTheDisk() throws {
        let sut = makeSUT()
        let folder = makeFolder(holding: 1)
        defer { throwAway(folder) }
        let held = FolderOnDisk.putAFolder(named: "held", inside: folder)

        let received = try sut.removeItem(at: held)

        #expect(received)
        #expect(sut.foldersInside(folder).isEmpty)
    }

    @Test
    func removeItem_saysNothingWasThereWhenThereIsNothingToRemove() throws {
        let sut = makeSUT()
        let folder = makeFolder(holding: 0)
        defer { throwAway(folder) }

        let received = try sut.removeItem(at: folder.appending(path: "never made"))

        #expect(received == false)
    }

    @Test("A folder that could not be deleted says what the disk said")
    func removeItem_throwsWhatTheDiskSaidWhenTheFolderCouldNotBeRemoved() {
        let sut = makeSUT()
        let folder = makeFolder(holding: 0)
        defer { throwAway(folder) }
        let held = FolderOnDisk.putAFolder(named: "cache", inside: folder)
        FolderOnDisk.makeUnwritable(folder)

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
        let folder = FolderOnDisk.made()
        for block in 0..<blocks {
            FolderOnDisk.put(blocks: 1, named: "block \(block)", inside: folder)
        }
        return folder
    }

    func throwAway(_ folder: URL) {
        FolderOnDisk.throwAway(folder)
    }
}
