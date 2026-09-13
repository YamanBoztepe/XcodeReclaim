public struct Simulator: Hashable {
    public let identifier: String
    public let name: String
    public let runtime: String
    public let isShutDown: Bool
    public let bytes: Int

    public init(identifier: String, name: String, runtime: String, isShutDown: Bool, bytes: Int) {
        self.identifier = identifier
        self.name = name
        self.runtime = runtime
        self.isShutDown = isShutDown
        self.bytes = bytes
    }
}
