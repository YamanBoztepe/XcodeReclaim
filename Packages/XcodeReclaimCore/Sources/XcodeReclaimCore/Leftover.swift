import Foundation

public struct Leftover: Hashable, Sendable {
    public enum Kind: Hashable, Sendable {
        case derivedData
        case interfaceBuilderCache
        case previews
        case documentationCache
        case deviceSupport(systemVersion: String?)
        case simulator(name: String, runtime: String)
        case xcodeCopy(version: XcodeVersion?, canBeRemovedWhereItStands: Bool)
    }

    public struct XcodeVersion: Hashable, Sendable {
        public let number: String
        public let build: String

        public init(number: String, build: String) {
            self.number = number
            self.build = build
        }
    }

    public enum Place: Hashable, Sendable {
        case folder(URL)
        case simulator(String)
        case xcodeCopy(URL)
    }

    public enum Refusal: Hashable, Sendable {
        case simulatorIsRunning
        case xcodeIsOpen
        case commandLineToolsPointAtIt
    }

    public let kind: Kind
    public let name: String
    public let bytes: Int
    public let place: Place
    public let cost: String?
    public let refusal: Refusal?

    public init(kind: Kind, name: String, bytes: Int, place: Place, cost: String? = nil, refusal: Refusal? = nil) {
        self.kind = kind
        self.name = name
        self.bytes = bytes
        self.place = place
        self.cost = cost
        self.refusal = refusal
    }
}
