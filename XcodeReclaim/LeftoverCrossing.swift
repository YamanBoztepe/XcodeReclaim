import Foundation
import XcodeReclaimCore

public struct LeftoverCrossing: Sendable {
    public enum PlaceCrossing: Sendable {
        case folder(URL)
        case simulator(String)
        case xcodeCopy(URL)
    }

    public enum RefusalCrossing: Sendable {
        case theSimulatorIsRunning
        case xcodeIsOpen
        case theCommandLineToolsPointAtIt
    }

    public let name: String
    public let bytes: Int
    public let place: PlaceCrossing
    public let cost: String?
    public let refusal: RefusalCrossing?

    public init(_ leftover: Leftover) {
        name = leftover.name
        bytes = leftover.bytes
        place = PlaceCrossing(leftover.place)
        cost = leftover.cost
        refusal = leftover.refusal.map(RefusalCrossing.init)
    }

    public var leftover: Leftover {
        Leftover(name: name, bytes: bytes, place: place.place, cost: cost, refusal: refusal?.refusal)
    }
}

public enum DeletionCrossing: Sendable {
    case freed(Int)
    case refused(LeftoverCrossing.RefusalCrossing)
    case failed(String)

    public init(_ deletion: Deletion) {
        switch deletion {
        case .freed(let bytes): self = .freed(bytes)
        case .refused(let refusal): self = .refused(LeftoverCrossing.RefusalCrossing(refusal))
        case .failed(let why): self = .failed(why)
        }
    }

    public var deletion: Deletion {
        switch self {
        case .freed(let bytes): .freed(bytes)
        case .refused(let refusal): .refused(refusal.refusal)
        case .failed(let why): .failed(why)
        }
    }
}

extension LeftoverCrossing.PlaceCrossing {
    public init(_ place: Leftover.Place) {
        switch place {
        case .folder(let url): self = .folder(url)
        case .simulator(let identifier): self = .simulator(identifier)
        case .xcodeCopy(let url): self = .xcodeCopy(url)
        }
    }

    public var place: Leftover.Place {
        switch self {
        case .folder(let url): .folder(url)
        case .simulator(let identifier): .simulator(identifier)
        case .xcodeCopy(let url): .xcodeCopy(url)
        }
    }
}

extension LeftoverCrossing.RefusalCrossing {
    public init(_ refusal: Leftover.Refusal) {
        switch refusal {
        case .theSimulatorIsRunning: self = .theSimulatorIsRunning
        case .xcodeIsOpen: self = .xcodeIsOpen
        case .theCommandLineToolsPointAtIt: self = .theCommandLineToolsPointAtIt
        }
    }

    public var refusal: Leftover.Refusal {
        switch self {
        case .theSimulatorIsRunning: .theSimulatorIsRunning
        case .xcodeIsOpen: .xcodeIsOpen
        case .theCommandLineToolsPointAtIt: .theCommandLineToolsPointAtIt
        }
    }
}
