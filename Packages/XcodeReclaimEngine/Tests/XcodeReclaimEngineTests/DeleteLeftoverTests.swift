import Foundation
import Testing
import XcodeReclaimCore
import XcodeReclaimEngine

struct DeleteLeftoverTests {
    @Test("A deleted leftover is gone from the folder")
    func delete_removesTheLeftoverFromTheFolderAndFreesItsRoom() {
        let roomItTook = 200
        let (sut, disk, _) = makeSUT()

        let received = sut.delete(derivedData(taking: roomItTook))

        #expect(disk.messages == [.removed(DeveloperFolder.derivedData)])
        #expect(received == .freed(roomItTook))
    }

    @Test("A deleted simulator delivers the room it took")
    func delete_freesTheRoomADeletedSimulatorTook() {
        let roomItTook = 200
        let (sut, _, simulators) = makeSUT()

        let received = sut.delete(simulator(taking: roomItTook))

        #expect(simulators.messages == [.deleted(deviceIdentifier)])
        #expect(received == .freed(roomItTook))
    }

    @Test("A running simulator is not deleted")
    func delete_refusesARunningSimulatorAndRemovesNothing() {
        let (sut, disk, _) = makeSUT()

        let received = sut.delete(simulator(refusedFor: .simulatorIsRunning))

        #expect(received == .refused(.simulatorIsRunning))
        #expect(disk.messages.isEmpty)
    }

    @Test("A simulator that cannot be deleted delivers no freed room")
    func delete_freesNoRoomWhenTheSimulatorCannotBeDeleted() {
        let roomItTook = 200
        let (sut, _, simulators) = makeSUT()
        simulators.deletion = .failure(WorldFailure(sentence: "the device is in use"))

        let received = sut.delete(simulator(taking: roomItTook))

        #expect(received.isFailure)
    }

    @Test("Deleting a leftover that is already gone frees nothing")
    func delete_freesNothingForALeftoverThatIsAlreadyGone() {
        let roomTheMeasuringSaidItTook = 200
        let (sut, disk, _) = makeSUT()
        disk.removal = .success(false)

        let received = sut.delete(derivedData(taking: roomTheMeasuringSaidItTook))

        #expect(received == .freed(0))
    }

    @Test("A simulator that is not shut down is not deleted")
    func delete_neverAsksTheServiceForASimulatorThatIsNotShutDown() {
        let (sut, _, simulators) = makeSUT()

        _ = sut.delete(simulator(refusedFor: .simulatorIsRunning))

        #expect(simulators.messages.isEmpty)
    }

    @Test("A leftover none of which could be deleted says so and stays")
    func delete_freesNoRoomWhenNoneOfTheLeftoverCouldBeDeleted() {
        let roomItTook = 200
        let whatTheDiskSaid = "you don't have permission to access it"
        let (sut, disk, _) = makeSUT()
        disk.removal = .failure(WorldFailure(sentence: whatTheDiskSaid))
        disk.sizes[DeveloperFolder.derivedData] = roomItTook

        let received = sut.delete(derivedData(taking: roomItTook))

        #expect(received == .failed(whatTheDiskSaid))
        #expect(disk.messages == [.removed(DeveloperFolder.derivedData), .sizeRead(DeveloperFolder.derivedData)])
    }

    @Test("A leftover only part of which could be deleted says what came back")
    func delete_saysWhatCameBackWhenOnlyPartOfTheLeftoverCouldBeDeleted() {
        let whatTheDiskSaid = "“DerivedData” couldn't be removed because you don't have permission to access it."
        let (sut, disk, _) = makeSUT()
        disk.removal = .failure(WorldFailure(sentence: whatTheDiskSaid))
        disk.sizes[DeveloperFolder.derivedData] = 50

        let received = sut.delete(derivedData(taking: 200))

        #expect(received == .partlyFreed(150, stillThere: 50, why: whatTheDiskSaid))
    }

    @Test("A copy emptied where the folder cannot be written frees the room it held")
    func delete_freesTheRoomACopyHeldWhenTheFolderItSitsInCannotBeWritten() {
        let roomItHeld = 4_000_000_000
        let (sut, disk, _) = makeSUT()
        disk.removal = .failure(WorldFailure(sentence: "you don't have permission to access it"))
        disk.whatCanBeRemoved[copyPath] = false

        let received = sut.delete(copyOfXcode(taking: roomItHeld))

        #expect(received == .freed(roomItHeld))
    }

    @Test("A folder that measures as empty after it refused frees nothing")
    func delete_freesNothingWhenTheFolderMeasuresAsEmptyAfterItRefused() {
        let whatTheDiskSaid = "you don't have permission to access it"
        let (sut, disk, _) = makeSUT()
        disk.removal = .failure(WorldFailure(sentence: whatTheDiskSaid))

        let received = sut.delete(derivedData(taking: 200))

        #expect(received == .failed(whatTheDiskSaid))
    }

    @Test("A failed deletion carries why it failed")
    func delete_carriesWhyItFailed() {
        let whatTheServiceSaid = "Invalid device"
        let (sut, _, simulators) = makeSUT()
        simulators.deletion = .failure(WorldFailure(sentence: whatTheServiceSaid))

        let received = sut.delete(simulator(taking: 200))

        #expect(received == .failed(whatTheServiceSaid))
    }

    @Test("A deletion frees the room the leftover was carrying")
    func delete_freesTheRoomTheLeftoverWasCarryingWithoutMeasuringAgain() {
        let roomItWasCarrying = 200
        let (sut, disk, _) = makeSUT()
        disk.sizes[DeveloperFolder.derivedData] = 27_702_730_752

        let received = sut.delete(derivedData(taking: roomItWasCarrying))

        #expect(received == .freed(roomItWasCarrying))
        #expect(disk.messages == [.removed(DeveloperFolder.derivedData)])
    }

    @Test("Deleting a copy of Xcode gives back the room it took")
    func delete_givesBackTheRoomACopyOfXcodeTook() {
        let roomItTook = 4_000_000_000
        let (sut, disk, _) = makeSUT()

        let received = sut.delete(copyOfXcode(taking: roomItTook))

        #expect(disk.messages == [.removed(copyPath)])
        #expect(received == .freed(roomItTook))
    }

    @Test("A copy of Xcode that could not be removed says what the disk said")
    func delete_saysWhatTheDiskSaidWhenACopyCouldNotBeRemoved() {
        let whatTheDiskSaid = "“Xcode.app” couldn't be removed because you don't have permission to access it."
        let (sut, disk, _) = makeSUT()
        disk.removal = .failure(WorldFailure(sentence: whatTheDiskSaid))

        let received = sut.delete(copyOfXcode(taking: 4_000_000_000))

        #expect(received == .failed(whatTheDiskSaid))
    }

    @Test("A leftover refused when it was measured is not deleted")
    func delete_refusesALeftoverForTheReasonTheMeasuringGave() {
        let refusedWhenItWasMeasured: [Leftover.Refusal] = [.xcodeIsOpen, .commandLineToolsPointAtIt]
        let (sut, disk, _) = makeSUT()

        let received = refusedWhenItWasMeasured.map { sut.delete(copyOfXcode(taking: 4_000_000_000, refusedFor: $0)) }

        #expect(received == [.refused(.xcodeIsOpen), .refused(.commandLineToolsPointAtIt)])
        #expect(disk.messages.isEmpty)
    }
}

private extension DeleteLeftoverTests {
    var deviceIdentifier: String { "21B507D3-909E-465B-957C-4B370278399F" }
    var copyPath: URL { URL(fileURLWithPath: "/Applications/Xcode 26.2.app") }

    func makeSUT() -> (sut: DeleteLeftover, disk: WorldSpy, simulators: SimulatorServiceSpy) {
        let disk = WorldSpy()
        let simulators = SimulatorServiceSpy()
        let sut = DeleteLeftover(disk: disk, simulatorService: simulators)
        return (sut, disk, simulators)
    }

    func derivedData(taking bytes: Int) -> Leftover {
        Leftover(kind: .derivedData, bytes: bytes, place: .folder(DeveloperFolder.derivedData))
    }

    func simulator(taking bytes: Int = 200, refusedFor refusal: Leftover.Refusal? = nil) -> Leftover {
        Leftover(
            kind: .simulator(name: "iPhone 17", runtime: "iOS 26.4"),
            bytes: bytes,
            place: .simulator(deviceIdentifier),
            refusal: refusal)
    }

    func copyOfXcode(taking bytes: Int, refusedFor refusal: Leftover.Refusal? = nil) -> Leftover {
        Leftover(
            kind: .xcodeCopy(version: Leftover.XcodeVersion(number: "26.2", build: "17C51"), canBeRemovedWhereItStands: true),
            bytes: bytes,
            place: .xcodeCopy(copyPath),
            refusal: refusal)
    }
}
