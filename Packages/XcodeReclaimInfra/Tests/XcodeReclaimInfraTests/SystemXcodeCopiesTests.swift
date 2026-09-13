import Foundation
import Testing
import XcodeReclaimEngine
import XcodeReclaimInfra

struct SystemXcodeCopiesTests {
    @Test
    func copies_deliversTheVersionAndBuildTheBundleDeclares() {
        let applications = AFolderOnTheDisk.made()
        defer { AFolderOnTheDisk.throwAway(applications) }
        let app = AnXcodeBundle.made(named: "Xcode 26.2.app", carrying: "26.2", build: "17C51", inside: applications)
        let (sut, tool, _) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .success(app.path(percentEncoded: false))

        let received = sut.copies()

        #expect(received.map(\.version) == [XcodeCopy.Version(number: "26.2", build: "17C51")])
        #expect(received.map(\.path) == [app])
    }

    @Test
    func copies_deliversNoVersionWhenTheBundleDeclaresNoBuild() {
        let applications = AFolderOnTheDisk.made()
        defer { AFolderOnTheDisk.throwAway(applications) }
        let app = AnXcodeBundle.madeCarryingNoBuild(named: "Xcode.app", carrying: "26.1.1", inside: applications)
        let (sut, tool, _) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .success(app.path(percentEncoded: false))

        let received = sut.copies()

        #expect(received.map(\.version) == [nil])
    }

    @Test("When the search answers nothing, the applications folder is read instead")
    func copies_readsTheApplicationsFolderWhenTheSearchAnswersNothing() {
        let roomItTakes = 4_000_000_000
        let applications = AFolderOnTheDisk.made()
        defer { AFolderOnTheDisk.throwAway(applications) }
        let app = AnXcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let somethingElse = AnXcodeBundle.madeForSomethingElse(named: "Safari.app", inside: applications)
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
        let applications = AFolderOnTheDisk.made()
        defer { AFolderOnTheDisk.throwAway(applications) }
        let app = AnXcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let (sut, tool, disk) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .failure(WhatTheWorldSaid(sentence: "the search is not running"))
        disk.folders[applications] = [app]
        disk.sizes[app] = roomItTakes

        let received = sut.copies()

        #expect(received.map(\.path) == [app])
        #expect(received.map(\.bytes) == [roomItTakes])
    }

    @Test("A machine with no copy of Xcode delivers none")
    func copies_deliversNoneOnAMachineWithNoCopyOfXcode() {
        let applications = AFolderOnTheDisk.made()
        defer { AFolderOnTheDisk.throwAway(applications) }
        let somethingElse = AnXcodeBundle.madeForSomethingElse(named: "Safari.app", inside: applications)
        let (sut, tool, disk) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .success("")
        disk.folders[applications] = [somethingElse]

        let received = sut.copies()

        #expect(received.isEmpty)
    }

    @Test
    func copies_deliversACopyAsOpenWhenSomethingInsideItIsRunning() {
        let applications = AFolderOnTheDisk.made()
        defer { AFolderOnTheDisk.throwAway(applications) }
        let open = AnXcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let beside = AnXcodeBundle.made(named: "Xcode 26.2.app", carrying: "26.2", build: "17C51", inside: applications)
        let (sut, tool, _) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .success("\(open.path(percentEncoded: false))\n\(beside.path(percentEncoded: false))")
        tool.answers["ps"] = .success("\(open.path(percentEncoded: false))/Contents/MacOS/Xcode")

        let received = sut.copies()

        #expect(received.map(\.isOpen) == [true, false])
    }

    @Test
    func copies_deliversNoCopyAsOpenWhenAnotherCopysNameStartsWithIts() {
        let applications = AFolderOnTheDisk.made()
        defer { AFolderOnTheDisk.throwAway(applications) }
        let shorter = AnXcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let longer = AnXcodeBundle.made(named: "Xcode.app.old", carrying: "26.2", build: "17C51", inside: applications)
        let (sut, tool, _) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .success("\(shorter.path(percentEncoded: false))\n\(longer.path(percentEncoded: false))")
        tool.answers["ps"] = .success("\(longer.path(percentEncoded: false))/Contents/MacOS/Xcode")

        let received = sut.copies()

        #expect(received.map(\.isOpen) == [false, true])
    }

    @Test
    func copies_deliversNoCopyAsPointedAtWhenAnotherCopysNameStartsWithIts() {
        let applications = AFolderOnTheDisk.made()
        defer { AFolderOnTheDisk.throwAway(applications) }
        let shorter = AnXcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let longer = AnXcodeBundle.made(named: "Xcode.app.old", carrying: "26.2", build: "17C51", inside: applications)
        let (sut, tool, _) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .success("\(shorter.path(percentEncoded: false))\n\(longer.path(percentEncoded: false))")
        tool.answers["xcode-select"] = .success("\(longer.path(percentEncoded: false))/Contents/Developer")

        let received = sut.copies()

        #expect(received.map(\.isPointedAtByTheCommandLineTools) == [false, true])
    }

    @Test
    func copies_deliversTheCopyHoldingTheDeveloperFolderAsTheOneTheToolsPointAt() {
        let applications = AFolderOnTheDisk.made()
        defer { AFolderOnTheDisk.throwAway(applications) }
        let pointedAt = AnXcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let beside = AnXcodeBundle.made(named: "Xcode 26.2.app", carrying: "26.2", build: "17C51", inside: applications)
        let (sut, tool, _) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .success("\(pointedAt.path(percentEncoded: false))\n\(beside.path(percentEncoded: false))")
        tool.answers["xcode-select"] = .success("\(pointedAt.path(percentEncoded: false))/Contents/Developer\n")

        let received = sut.copies()

        #expect(received.map(\.isPointedAtByTheCommandLineTools) == [true, false])
    }

    @Test
    func copies_deliversNoCopyAsOpenWhenTheMachineCannotSayWhatIsRunning() {
        let applications = AFolderOnTheDisk.made()
        defer { AFolderOnTheDisk.throwAway(applications) }
        let app = AnXcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let (sut, tool, _) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .success(app.path(percentEncoded: false))
        tool.answers["ps"] = .failure(WhatTheWorldSaid(sentence: "ps cannot be run"))

        let received = sut.copies()

        #expect(received.map(\.isOpen) == [false])
    }

    @Test
    func copies_deliversNoCopyAsPointedAtWhenTheToolsCannotBeAsked() {
        let applications = AFolderOnTheDisk.made()
        defer { AFolderOnTheDisk.throwAway(applications) }
        let app = AnXcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let (sut, tool, _) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .success(app.path(percentEncoded: false))
        tool.answers["xcode-select"] = .failure(WhatTheWorldSaid(sentence: "xcode-select cannot be run"))

        let received = sut.copies()

        #expect(received.map(\.isPointedAtByTheCommandLineTools) == [false])
    }

    @Test
    func copies_deliversEveryCopyASearchNamedOverSeveralLines() {
        let applications = AFolderOnTheDisk.made()
        defer { AFolderOnTheDisk.throwAway(applications) }
        let first = AnXcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let second = AnXcodeBundle.made(named: "Xcode 26.2.app", carrying: "26.2", build: "17C51", inside: applications)
        let (sut, tool, _) = makeSUT(applicationsFolder: applications)
        tool.answers["mdfind"] = .success("\(first.path(percentEncoded: false))\r\n\(second.path(percentEncoded: false))\n")

        let received = sut.copies()

        #expect(received.map(\.path) == [first, second])
    }

    @Test("A file with more than one path is counted once")
    func copies_countsAFileWithMoreThanOnePathOnce() {
        let applications = AFolderOnTheDisk.made()
        defer { AFolderOnTheDisk.throwAway(applications) }
        let app = AFolderOnTheDisk.putAFolder(named: "Xcode.app", inside: applications)
        AFolderOnTheDisk.put(1, named: "one block", inside: app)
        AFolderOnTheDisk.putASecondPathTo("one block", named: "the same block again", inside: app)
        let (sut, tool) = makeSUTReadingTheRealDisk(applicationsFolder: applications)
        tool.answers["mdfind"] = .success(app.path(percentEncoded: false))

        let received = sut.copies()

        #expect(received.map(\.bytes) == [AFolderOnTheDisk.oneBlock])
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
