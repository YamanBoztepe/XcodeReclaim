import Foundation

public struct Runtime: Hashable {
    public let identifier: String
    public let name: String
    public let build: String
    public let simulatorRuntime: String
    public let lastUsed: Date?
    public let bytes: Int

    public init(identifier: String, name: String, build: String, simulatorRuntime: String, lastUsed: Date?, bytes: Int) {
        self.identifier = identifier
        self.name = name
        self.build = build
        self.simulatorRuntime = simulatorRuntime
        self.lastUsed = lastUsed
        self.bytes = bytes
    }
}
