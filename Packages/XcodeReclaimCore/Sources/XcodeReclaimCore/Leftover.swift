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
        case runtime(name: String, build: String, lastUsed: Date?)
        case archive(name: String, version: String?, build: String?, created: Date?)
        case swiftPackageCache
        case toolchain(name: String)
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
        case runtime(String)
    }

    public enum Refusal: Hashable, Sendable {
        case simulatorIsRunning
        case xcodeIsOpen
        case commandLineToolsPointAtIt
        case runtimeIsInUse
        case swiftLatestPointsAtIt
    }

    public let kind: Kind
    public let bytes: Int
    public let place: Place
    public let refusal: Refusal?

    public init(kind: Kind, bytes: Int, place: Place, refusal: Refusal? = nil) {
        self.kind = kind
        self.bytes = bytes
        self.place = place
        self.refusal = refusal
    }
}
