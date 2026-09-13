import Foundation

public struct Leftover: Hashable, Sendable {
    public enum Place: Hashable, Sendable {
        case folder(URL)
        case simulator(String)
        case xcodeCopy(URL)
    }

    public enum Refusal: Hashable, Sendable {
        case theSimulatorIsRunning
        case xcodeIsOpen
        case theCommandLineToolsPointAtIt
    }

    public let name: String
    public let bytes: Int
    public let place: Place
    public let cost: String?
    public let refusal: Refusal?

    public init(name: String, bytes: Int, place: Place, cost: String? = nil, refusal: Refusal? = nil) {
        self.name = name
        self.bytes = bytes
        self.place = place
        self.cost = cost
        self.refusal = refusal
    }
}
