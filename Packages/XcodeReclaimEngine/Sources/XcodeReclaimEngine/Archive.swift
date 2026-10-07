import Foundation

public struct Archive: Hashable {
    public let path: URL
    public let name: String
    public let version: String?
    public let build: String?
    public let created: Date?
    public let bytes: Int

    public init(path: URL, name: String, version: String?, build: String?, created: Date?, bytes: Int) {
        self.path = path
        self.name = name
        self.version = version
        self.build = build
        self.created = created
        self.bytes = bytes
    }
}
