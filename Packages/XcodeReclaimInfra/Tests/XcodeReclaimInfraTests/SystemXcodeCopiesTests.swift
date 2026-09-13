import Foundation
import Testing
import XcodeReclaimEngine
import XcodeReclaimInfra

struct SystemXcodeCopiesTests {
    @Test
    func copies_deliversTheVersionAndBuildTheBundleDeclares() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let app = XcodeBundle.made(named: "Xcode 26.2.app", carrying: "26.2", build: "17C51", inside: applications)
        let (sut, tool, _) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .success(app.path(percentEncoded: false))

        let received = sut.copies()

        #expect(received.map(\.version) == [XcodeCopy.Version(number: "26.2", build: "17C51")])
        #expect(received.map(\.path) == [app])
    }

    @Test
    func copies_deliversNoVersionWhenTheBundleDeclaresNoBuild() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let app = XcodeBundle.madeCarryingNoBuild(named: "Xcode.app", carrying: "26.1.1", inside: applications)
        let (sut, tool, _) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .success(app.path(percentEncoded: false))

        let received = sut.copies()

        #expect(received.map(\.version) == [nil])
    }

    @Test("When the search answers nothing, the applications folder is read instead")
    func copies_readsTheApplicationsFolderWhenTheSearchAnswersNothing() {
        let roomItTakes = 4_000_000_000
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let app = XcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let somethingElse = XcodeBundle.madeForSomethingElse(named: "Safari.app", inside: applications)
        let (sut, tool, disk) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .success("")
        disk.folders[applications] = [app, somethingElse]
        disk.sizes[app] = roomItTakes

        let received = sut.copies()

        #expect(received.map(\.path) == [app])
        #expect(received.map(\.bytes) == [roomItTakes])
    }

    @Test("When the search cannot be asked, the applications folder is read instead")
    func copies_readsTheApplicationsFolderWhenTheSearchCannotBeAsked() {
        let roomItTakes = 4_000_000_000
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let app = XcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let (sut, tool, disk) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .failure(WorldFailure(sentence: "the search is not running"))
        disk.folders[applications] = [app]
        disk.sizes[app] = roomItTakes

        let received = sut.copies()

        #expect(received.map(\.path) == [app])
        #expect(received.map(\.bytes) == [roomItTakes])
    }

    @Test("A machine with no copy of Xcode delivers none")
    func copies_deliversNoneOnAMachineWithNoCopyOfXcode() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let somethingElse = XcodeBundle.madeForSomethingElse(named: "Safari.app", inside: applications)
        let (sut, tool, disk) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .success("")
        disk.folders[applications] = [somethingElse]

        let received = sut.copies()

        #expect(received.isEmpty)
    }

    @Test
    func copies_deliversACopyAsOpenWhenSomethingInsideItIsRunning() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let open = XcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let beside = XcodeBundle.made(named: "Xcode 26.2.app", carrying: "26.2", build: "17C51", inside: applications)
        let (sut, tool, _) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .success("\(open.path(percentEncoded: false))\n\(beside.path(percentEncoded: false))")
        tool.answers["ps"] = .success("\(open.path(percentEncoded: false))/Contents/MacOS/Xcode")

        let received = sut.copies()

        #expect(received.map(\.isOpen) == [true, false])
    }

    @Test
    func copies_deliversNoCopyAsOpenWhenAnotherCopysNameStartsWithIts() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let shorter = XcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let longer = XcodeBundle.made(named: "Xcode.app.old", carrying: "26.2", build: "17C51", inside: applications)
        let (sut, tool, _) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .success("\(shorter.path(percentEncoded: false))\n\(longer.path(percentEncoded: false))")
        tool.answers["ps"] = .success("\(longer.path(percentEncoded: false))/Contents/MacOS/Xcode")

        let received = sut.copies()

        #expect(received.map(\.isOpen) == [false, true])
    }

    @Test
    func copies_deliversNoCopyAsPointedAtWhenAnotherCopysNameStartsWithIts() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let shorter = XcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let longer = XcodeBundle.made(named: "Xcode.app.old", carrying: "26.2", build: "17C51", inside: applications)
        let (sut, tool, _) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .success("\(shorter.path(percentEncoded: false))\n\(longer.path(percentEncoded: false))")
        tool.answers["xcode-select"] = .success("\(longer.path(percentEncoded: false))/Contents/Developer")

        let received = sut.copies()

        #expect(received.map(\.isPointedAtByCommandLineTools) == [false, true])
    }

    @Test
    func copies_deliversTheCopyHoldingTheDeveloperFolderAsTheOneTheToolsPointAt() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let pointedAt = XcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let beside = XcodeBundle.made(named: "Xcode 26.2.app", carrying: "26.2", build: "17C51", inside: applications)
        let (sut, tool, _) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .success("\(pointedAt.path(percentEncoded: false))\n\(beside.path(percentEncoded: false))")
        tool.answers["xcode-select"] = .success("\(pointedAt.path(percentEncoded: false))/Contents/Developer\n")

        let received = sut.copies()

        #expect(received.map(\.isPointedAtByCommandLineTools) == [true, false])
    }

    @Test
    func copies_deliversNoCopyAsOpenWhenTheMachineCannotSayWhatIsRunning() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let app = XcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let (sut, tool, _) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .success(app.path(percentEncoded: false))
        tool.answers["ps"] = .failure(WorldFailure(sentence: "ps cannot be run"))

        let received = sut.copies()

        #expect(received.map(\.isOpen) == [false])
    }

    @Test
    func copies_deliversNoCopyAsPointedAtWhenTheToolsCannotBeAsked() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let app = XcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let (sut, tool, _) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .success(app.path(percentEncoded: false))
        tool.answers["xcode-select"] = .failure(WorldFailure(sentence: "xcode-select cannot be run"))

        let received = sut.copies()

        #expect(received.map(\.isPointedAtByCommandLineTools) == [false])
    }

    @Test
    func copies_deliversEveryCopyASearchNamedOverSeveralLines() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let first = XcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let second = XcodeBundle.made(named: "Xcode 26.2.app", carrying: "26.2", build: "17C51", inside: applications)
        let (sut, tool, _) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .success("\(first.path(percentEncoded: false))\r\n\(second.path(percentEncoded: false))\n")

        let received = sut.copies()

        #expect(received.map(\.path) == [first, second])
    }

    @Test("A file with more than one path is counted once")
    func copies_countsAFileWithMoreThanOnePathOnce() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let app = FolderOnDisk.putAFolder(named: "Xcode.app", inside: applications)
        FolderOnDisk.put(1, named: "one block", inside: app)
        FolderOnDisk.putASecondPathTo("one block", named: "the same block again", inside: app)
        let (sut, tool) = makeSUTReadingTheRealDisk(applicationsFolder: applications)
        tool.answers["mdfind"] = .success(app.path(percentEncoded: false))

        let received = sut.copies()

        #expect(received.map(\.bytes) == [FolderOnDisk.oneBlock])
    }
}

private extension SystemXcodeCopiesTests {
    func makeSUT(applicationsFolder: URL) -> (sut: SystemXcodeCopies, tool: ToolSpy, disk: DiskStub) {
        let tool = ToolSpy()
        let disk = DiskStub()
        let sut = SystemXcodeCopies(tool: tool, disk: disk, applicationsFolder: applicationsFolder)
        return (sut, tool, disk)
    }

    func makeSUTReadingTheRealDisk(applicationsFolder: URL) -> (sut: SystemXcodeCopies, tool: ToolSpy) {
        let tool = ToolSpy()
        let sut = SystemXcodeCopies(tool: tool, disk: FileManagerDisk(), applicationsFolder: applicationsFolder)
        return (sut, tool)
    }
}
