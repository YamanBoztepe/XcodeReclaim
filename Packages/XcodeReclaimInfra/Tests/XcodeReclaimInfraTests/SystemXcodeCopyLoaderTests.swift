import Foundation
import Testing
import XcodeReclaimEngine
import XcodeReclaimInfra

struct SystemXcodeCopyLoaderTests {
    @Test
    func load_deliversTheVersionAndBuildTheBundleDeclares() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let app = XcodeBundle.made(named: "Xcode 26.2.app", carrying: "26.2", build: "17C51", inside: applications)
        let (sut, commandRunner, _) = makeSUT(applicationsFolder: applications)
        commandRunner.answers["mdfind"] = .success(app.path(percentEncoded: false))

        let received = sut.load()

        #expect(received.map(\.version) == [XcodeCopy.Version(number: "26.2", build: "17C51")])
        #expect(received.map(\.path) == [app])
    }

    @Test
    func load_deliversWhetherTheCopyCanBeRemovedWhereItStands() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let app = XcodeBundle.made(named: "Xcode 26.2.app", carrying: "26.2", build: "17C51", inside: applications)
        let (sut, commandRunner, disk) = makeSUT(applicationsFolder: applications)
        commandRunner.answers["mdfind"] = .success(app.path(percentEncoded: false))
        disk.whatCanBeRemoved[app] = false

        let received = sut.load()

        #expect(received.map(\.canBeRemoved) == [false])
    }

    @Test
    func load_deliversNoVersionWhenTheBundleDeclaresNoBuild() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let app = XcodeBundle.madeCarryingNoBuild(named: "Xcode.app", carrying: "26.1.1", inside: applications)
        let (sut, commandRunner, _) = makeSUT(applicationsFolder: applications)
        commandRunner.answers["mdfind"] = .success(app.path(percentEncoded: false))

        let received = sut.load()

        #expect(received.map(\.version) == [nil])
    }

    @Test("When the search answers nothing, the applications folder is read instead")
    func load_readsTheApplicationsFolderWhenTheSearchAnswersNothing() {
        let roomItTakes = 4_000_000_000
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let app = XcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let somethingElse = XcodeBundle.madeForSomethingElse(named: "Safari.app", inside: applications)
        let (sut, commandRunner, disk) = makeSUT(applicationsFolder: applications)
        commandRunner.answers["mdfind"] = .success("")
        disk.folders[applications] = [app, somethingElse]
        disk.sizes[app] = roomItTakes

        let received = sut.load()

        #expect(received.map(\.path) == [app])
        #expect(received.map(\.bytes) == [roomItTakes])
    }

    @Test("When the search cannot be asked, the applications folder is read instead")
    func load_readsTheApplicationsFolderWhenTheSearchCannotBeAsked() {
        let roomItTakes = 4_000_000_000
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let app = XcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let (sut, commandRunner, disk) = makeSUT(applicationsFolder: applications)
        commandRunner.answers["mdfind"] = .failure(WorldFailure(sentence: "the search is not running"))
        disk.folders[applications] = [app]
        disk.sizes[app] = roomItTakes

        let received = sut.load()

        #expect(received.map(\.path) == [app])
        #expect(received.map(\.bytes) == [roomItTakes])
    }

    @Test("A machine with no copy of Xcode delivers none")
    func load_deliversNoneOnAMachineWithNoCopyOfXcode() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let somethingElse = XcodeBundle.madeForSomethingElse(named: "Safari.app", inside: applications)
        let (sut, commandRunner, disk) = makeSUT(applicationsFolder: applications)
        commandRunner.answers["mdfind"] = .success("")
        disk.folders[applications] = [somethingElse]

        let received = sut.load()

        #expect(received.isEmpty)
    }

    @Test
    func load_deliversACopyAsOpenWhenSomethingInsideItIsRunning() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let open = XcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let beside = XcodeBundle.made(named: "Xcode 26.2.app", carrying: "26.2", build: "17C51", inside: applications)
        let (sut, commandRunner, _) = makeSUT(applicationsFolder: applications)
        commandRunner.answers["mdfind"] = .success("\(open.path(percentEncoded: false))\n\(beside.path(percentEncoded: false))")
        commandRunner.answers["ps"] = .success("\(open.path(percentEncoded: false))/Contents/MacOS/Xcode")

        let received = sut.load()

        #expect(received.map(\.isOpen) == [true, false])
    }

    @Test
    func load_deliversNoCopyAsOpenWhenAnotherCopysNameStartsWithIts() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let shorter = XcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let longer = XcodeBundle.made(named: "Xcode.app.old", carrying: "26.2", build: "17C51", inside: applications)
        let (sut, commandRunner, _) = makeSUT(applicationsFolder: applications)
        commandRunner.answers["mdfind"] = .success("\(shorter.path(percentEncoded: false))\n\(longer.path(percentEncoded: false))")
        commandRunner.answers["ps"] = .success("\(longer.path(percentEncoded: false))/Contents/MacOS/Xcode")

        let received = sut.load()

        #expect(received.map(\.isOpen) == [false, true])
    }

    @Test
    func load_deliversNoCopyAsPointedAtWhenAnotherCopysNameStartsWithIts() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let shorter = XcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let longer = XcodeBundle.made(named: "Xcode.app.old", carrying: "26.2", build: "17C51", inside: applications)
        let (sut, commandRunner, _) = makeSUT(applicationsFolder: applications)
        commandRunner.answers["mdfind"] = .success("\(shorter.path(percentEncoded: false))\n\(longer.path(percentEncoded: false))")
        commandRunner.answers["xcode-select"] = .success("\(longer.path(percentEncoded: false))/Contents/Developer")

        let received = sut.load()

        #expect(received.map(\.isPointedAtByCommandLineTools) == [false, true])
    }

    @Test
    func load_deliversTheCopyHoldingTheDeveloperFolderAsTheOneTheToolsPointAt() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let pointedAt = XcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let beside = XcodeBundle.made(named: "Xcode 26.2.app", carrying: "26.2", build: "17C51", inside: applications)
        let (sut, commandRunner, _) = makeSUT(applicationsFolder: applications)
        commandRunner.answers["mdfind"] = .success("\(pointedAt.path(percentEncoded: false))\n\(beside.path(percentEncoded: false))")
        commandRunner.answers["xcode-select"] = .success("\(pointedAt.path(percentEncoded: false))/Contents/Developer\n")

        let received = sut.load()

        #expect(received.map(\.isPointedAtByCommandLineTools) == [true, false])
    }

    @Test
    func load_deliversNoCopyAsOpenWhenTheMachineCannotSayWhatIsRunning() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let app = XcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let (sut, commandRunner, _) = makeSUT(applicationsFolder: applications)
        commandRunner.answers["mdfind"] = .success(app.path(percentEncoded: false))
        commandRunner.answers["ps"] = .failure(WorldFailure(sentence: "ps cannot be run"))

        let received = sut.load()

        #expect(received.map(\.isOpen) == [false])
    }

    @Test
    func load_deliversNoCopyAsPointedAtWhenTheToolsCannotBeAsked() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let app = XcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let (sut, commandRunner, _) = makeSUT(applicationsFolder: applications)
        commandRunner.answers["mdfind"] = .success(app.path(percentEncoded: false))
        commandRunner.answers["xcode-select"] = .failure(WorldFailure(sentence: "xcode-select cannot be run"))

        let received = sut.load()

        #expect(received.map(\.isPointedAtByCommandLineTools) == [false])
    }

    @Test
    func load_deliversEveryCopyASearchNamedOverSeveralLines() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let first = XcodeBundle.made(named: "Xcode.app", carrying: "26.4.1", build: "17E201", inside: applications)
        let second = XcodeBundle.made(named: "Xcode 26.2.app", carrying: "26.2", build: "17C51", inside: applications)
        let (sut, commandRunner, _) = makeSUT(applicationsFolder: applications)
        commandRunner.answers["mdfind"] = .success("\(first.path(percentEncoded: false))\r\n\(second.path(percentEncoded: false))\n")

        let received = sut.load()

        #expect(received.map(\.path) == [first, second])
    }

    @Test("A file with more than one path is counted once")
    func load_countsAFileWithMoreThanOnePathOnce() {
        let applications = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(applications) }
        let app = FolderOnDisk.putAFolder(named: "Xcode.app", inside: applications)
        FolderOnDisk.put(blocks: 1, named: "one block", inside: app)
        FolderOnDisk.putASecondPathTo("one block", named: "the same block again", inside: app)
        let (sut, commandRunner) = makeSUTReadingTheRealDisk(applicationsFolder: applications)
        commandRunner.answers["mdfind"] = .success(app.path(percentEncoded: false))

        let received = sut.load()

        #expect(received.map(\.bytes) == [FolderOnDisk.oneBlock])
    }
}

private extension SystemXcodeCopyLoaderTests {
    func makeSUT(applicationsFolder: URL) -> (sut: SystemXcodeCopyLoader, commandRunner: CommandRunnerSpy, disk: DiskStub) {
        let commandRunner = CommandRunnerSpy()
        let disk = DiskStub()
        let sut = SystemXcodeCopyLoader(commandRunner: commandRunner, disk: disk, applicationsFolder: applicationsFolder)
        return (sut, commandRunner, disk)
    }

    func makeSUTReadingTheRealDisk(applicationsFolder: URL) -> (sut: SystemXcodeCopyLoader, commandRunner: CommandRunnerSpy) {
        let commandRunner = CommandRunnerSpy()
        let sut = SystemXcodeCopyLoader(commandRunner: commandRunner, disk: FileManagerDisk(), applicationsFolder: applicationsFolder)
        return (sut, commandRunner)
    }
}
