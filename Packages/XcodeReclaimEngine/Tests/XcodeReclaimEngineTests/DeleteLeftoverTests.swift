import Foundation
import Testing
import XcodeReclaimCore
import XcodeReclaimEngine

struct DeleteLeftoverTests {
    @Test func aDeletedLeftoverIsGoneFromTheFolder() {
        let roomItTook = 200
        let (sut, disk, _) = makeSUT()

        let received = sut.delete(derivedData(taking: roomItTook))

        #expect(disk.messages == [.removed(DeveloperFolder.derivedData)])
        #expect(received == .freed(roomItTook))
    }

    @Test func aDeletedSimulatorDeliversTheRoomItTook() {
        let roomItTook = 200
        let (sut, _, simulators) = makeSUT()

        let received = sut.delete(simulator(taking: roomItTook))

        #expect(simulators.messages == [.deleted(deviceIdentifier)])
        #expect(received == .freed(roomItTook))
    }

    @Test func aRunningSimulatorIsNotDeleted() {
        let (sut, disk, _) = makeSUT()

        let received = sut.delete(simulator(refusedFor: .theSimulatorIsRunning))

        #expect(received == .refused(.theSimulatorIsRunning))
        #expect(disk.messages.isEmpty)
    }

    @Test func aSimulatorThatCannotBeDeletedDeliversNoFreedRoom() {
        let roomItTook = 200
        let (sut, _, simulators) = makeSUT()
        simulators.deletion = .failure(WhatTheWorldSaid(sentence: "the device is in use"))

        let received = sut.delete(simulator(taking: roomItTook))

        #expect(received != .freed(roomItTook))
    }

    @Test func deletingALeftoverThatIsAlreadyGoneFreesNothing() {
        let (sut, _, _) = makeSUT()

        let received = sut.delete(derivedData(taking: 0))

        #expect(received == .freed(0))
    }

    @Test func aSimulatorThatIsNotShutDownIsNotDeleted() {
        let (sut, _, simulators) = makeSUT()

        _ = sut.delete(simulator(refusedFor: .theSimulatorIsRunning))

        #expect(simulators.messages.isEmpty)
    }

    @Test func aLeftoverNoneOfWhichCouldBeDeletedSaysSoAndStays() {
        let roomItTook = 200
        let (sut, disk, _) = makeSUT()
        disk.removal = .failure(WhatTheWorldSaid(sentence: "you don't have permission to access it"))

        let received = sut.delete(derivedData(taking: roomItTook))

        #expect(received != .freed(roomItTook))
        #expect(disk.messages == [.removed(DeveloperFolder.derivedData)])
    }

    @Test func aFailedDeletionCarriesWhyItFailed() {
        let whatTheServiceSaid = "Invalid device"
        let (sut, _, simulators) = makeSUT()
        simulators.deletion = .failure(WhatTheWorldSaid(sentence: whatTheServiceSaid))

        let received = sut.delete(simulator(taking: 200))

        #expect(received == .failed(whatTheServiceSaid))
    }

    @Test func aDeletionFreesTheRoomTheLeftoverWasCarrying() {
        let roomItWasCarrying = 200
        let (sut, disk, _) = makeSUT()
        disk.sizes[DeveloperFolder.derivedData] = 27_702_730_752

        let received = sut.delete(derivedData(taking: roomItWasCarrying))

        #expect(received == .freed(roomItWasCarrying))
        #expect(disk.messages == [.removed(DeveloperFolder.derivedData)])
    }

    @Test func deletingACopyOfXcodeGivesBackTheRoomItTook() {
        let roomItTook = 4_000_000_000
        let (sut, disk, _) = makeSUT()

        let received = sut.delete(copyOfXcode(taking: roomItTook))

        #expect(disk.messages == [.removed(copyPath)])
        #expect(received == .freed(roomItTook))
    }

    @Test func aCopyOfXcodeThatCouldNotBeRemovedSaysWhatTheDiskSaid() {
        let whatTheDiskSaid = "“Xcode.app” couldn't be removed because you don't have permission to access it."
        let (sut, disk, _) = makeSUT()
        disk.removal = .failure(WhatTheWorldSaid(sentence: whatTheDiskSaid))

        let received = sut.delete(copyOfXcode(taking: 4_000_000_000))

        #expect(received == .failed(whatTheDiskSaid))
    }

    @Test func aLeftoverRefusedWhenItWasMeasuredIsNotDeleted() {
        let refusedWhenItWasMeasured: [Leftover.Refusal] = [.xcodeIsOpen, .theCommandLineToolsPointAtIt]
        let (sut, disk, _) = makeSUT()

        let received = refusedWhenItWasMeasured.map { sut.delete(copyOfXcode(taking: 4_000_000_000, refusedFor: $0)) }

        #expect(received == [.refused(.xcodeIsOpen), .refused(.theCommandLineToolsPointAtIt)])
        #expect(disk.messages.isEmpty)
    }
}

private extension DeleteLeftoverTests {
    var deviceIdentifier: String { "21B507D3-909E-465B-957C-4B370278399F" }
    var copyPath: URL { URL(fileURLWithPath: "/Applications/Xcode 26.2.app") }

    func makeSUT() -> (sut: DeleteLeftover, disk: DiskSpy, simulators: SimulatorServiceSpy) {
        let disk = DiskSpy()
        let simulators = SimulatorServiceSpy()
        let sut = DeleteLeftover(disk: disk, simulatorService: simulators)
        return (sut, disk, simulators)
    }

    func derivedData(taking bytes: Int) -> Leftover {
        Leftover(name: "Derived data", bytes: bytes, place: .folder(DeveloperFolder.derivedData))
    }

    func simulator(taking bytes: Int = 200, refusedFor refusal: Leftover.Refusal? = nil) -> Leftover {
        Leftover(name: "iPhone 17 (iOS 26.4, 21B507D3)", bytes: bytes, place: .simulator(deviceIdentifier), refusal: refusal)
    }

    func copyOfXcode(taking bytes: Int, refusedFor refusal: Leftover.Refusal? = nil) -> Leftover {
        Leftover(name: "Xcode 26.2 (17C51) — Applications", bytes: bytes, place: .xcodeCopy(copyPath), refusal: refusal)
    }
}
