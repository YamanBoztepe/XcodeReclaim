import Foundation

public struct XcodeCopy: Hashable {
    public struct Version: Hashable {
        public let number: String
        public let build: String

        public init(number: String, build: String) {
            self.number = number
            self.build = build
        }
    }

    public let path: URL
    public let version: Version?
    public let bytes: Int
    public let isOpen: Bool
    public let isPointedAtByTheCommandLineTools: Bool

    public init(path: URL, version: Version?, bytes: Int, isOpen: Bool, isPointedAtByTheCommandLineTools: Bool) {
        self.path = path
        self.version = version
        self.bytes = bytes
        self.isOpen = isOpen
        self.isPointedAtByTheCommandLineTools = isPointedAtByTheCommandLineTools
    }
}
