import Foundation
import XcodeReclaimCore

struct LeftoverCrossing: Sendable {
    enum PlaceCrossing: Sendable {
        case folder(URL)
        case simulator(String)
        case xcodeCopy(URL)
    }

    enum RefusalCrossing: Sendable {
        case theSimulatorIsRunning
        case xcodeIsOpen
        case theCommandLineToolsPointAtIt
    }

    let name: String
    let bytes: Int
    let place: PlaceCrossing
    let cost: String?
    let refusal: RefusalCrossing?

    init(_ leftover: Leftover) {
        name = leftover.name
        bytes = leftover.bytes
        place = PlaceCrossing(leftover.place)
        cost = leftover.cost
        refusal = leftover.refusal.map(RefusalCrossing.init)
    }

    var leftover: Leftover {
        Leftover(name: name, bytes: bytes, place: place.place, cost: cost, refusal: refusal?.refusal)
    }
}

enum DeletionCrossing: Sendable {
    case freed(Int)
    case refused(LeftoverCrossing.RefusalCrossing)
    case failed(String)

    init(_ deletion: Deletion) {
        switch deletion {
        case .freed(let bytes): self = .freed(bytes)
        case .refused(let refusal): self = .refused(LeftoverCrossing.RefusalCrossing(refusal))
        case .failed(let why): self = .failed(why)
        }
    }

    var deletion: Deletion {
        switch self {
        case .freed(let bytes): .freed(bytes)
        case .refused(let refusal): .refused(refusal.refusal)
        case .failed(let why): .failed(why)
        }
    }
}

extension LeftoverCrossing.PlaceCrossing {
    init(_ place: Leftover.Place) {
        switch place {
        case .folder(let url): self = .folder(url)
        case .simulator(let identifier): self = .simulator(identifier)
        case .xcodeCopy(let url): self = .xcodeCopy(url)
        }
    }

    var place: Leftover.Place {
        switch self {
        case .folder(let url): .folder(url)
        case .simulator(let identifier): .simulator(identifier)
        case .xcodeCopy(let url): .xcodeCopy(url)
        }
    }
}

extension LeftoverCrossing.RefusalCrossing {
    init(_ refusal: Leftover.Refusal) {
        switch refusal {
        case .theSimulatorIsRunning: self = .theSimulatorIsRunning
        case .xcodeIsOpen: self = .xcodeIsOpen
        case .theCommandLineToolsPointAtIt: self = .theCommandLineToolsPointAtIt
        }
    }

    var refusal: Leftover.Refusal {
        switch self {
        case .theSimulatorIsRunning: .theSimulatorIsRunning
        case .xcodeIsOpen: .xcodeIsOpen
        case .theCommandLineToolsPointAtIt: .theCommandLineToolsPointAtIt
        }
    }
}
