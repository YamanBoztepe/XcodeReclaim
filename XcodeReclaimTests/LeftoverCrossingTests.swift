import Foundation
import Testing
import XcodeReclaim
import XcodeReclaimCore

struct LeftoverCrossingTests {
    @Test func aLeftoverBuiltForCrossingIsTheSameLeftoverOnTheFarSide() {
        let crossing = everyShapeALeftoverTakes.map(LeftoverCrossing.init)

        let rebuilt = crossing.map(\.leftover)

        #expect(rebuilt == everyShapeALeftoverTakes)
    }

    @Test func aDeletionBuiltForCrossingIsTheSameDeletionOnTheFarSide() {
        let roomACopyTakes = 4_000_000_000
        let everyShapeADeletionTakes: [Deletion] = [
            .freed(0),
            .freed(roomACopyTakes),
            .refused(.theSimulatorIsRunning),
            .refused(.xcodeIsOpen),
            .refused(.theCommandLineToolsPointAtIt),
            .failed("Invalid device"),
        ]

        let rebuilt = everyShapeADeletionTakes.map(DeletionCrossing.init).map(\.deletion)

        #expect(rebuilt == everyShapeADeletionTakes)
    }
}

private extension LeftoverCrossingTests {
    var everyShapeALeftoverTakes: [Leftover] {
        let roomADeviceTakes = 4_557_963_264
        let roomACopyTakes = 3_941_601_280
        let roomAnotherCopyTakes = 4_000_000_000
        let roomDerivedDataTakes = 200
        return [
            Leftover(name: "Derived data", bytes: roomDerivedDataTakes, place: .folder(URL(filePath: "/developer/Xcode/DerivedData"))),
            Leftover(name: "Previews", bytes: 0, place: .folder(URL(filePath: "/developer/Xcode/UserData/Previews")), cost: "the previews are built again"),
            Leftover(
                name: "iPhone 17 (iOS 26.4, 21B507D3)",
                bytes: roomADeviceTakes,
                place: .simulator("21B507D3-909E-465B-957C-4B370278399F"),
                cost: "the apps inside it and their data are gone",
                refusal: .theSimulatorIsRunning),
            Leftover(
                name: "Xcode 26.2 (17C51) — Applications",
                bytes: roomACopyTakes,
                place: .xcodeCopy(URL(filePath: "/Applications/Xcode 26.2.app")),
                cost: "that version has to be downloaded again",
                refusal: .xcodeIsOpen),
            Leftover(
                name: "Xcode — Desktop",
                bytes: roomAnotherCopyTakes,
                place: .xcodeCopy(URL(filePath: "/Users/someone/Desktop/Xcode.app")),
                cost: "that version has to be downloaded again",
                refusal: .theCommandLineToolsPointAtIt),
        ]
    }
}
