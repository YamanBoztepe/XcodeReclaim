import Foundation

public struct Toolchain: Hashable {
    public let path: URL
    public let name: String
    public let isPointedAtBySwiftLatest: Bool
    public let bytes: Int

    public init(path: URL, name: String, isPointedAtBySwiftLatest: Bool, bytes: Int) {
        self.path = path
        self.name = name
        self.isPointedAtBySwiftLatest = isPointedAtBySwiftLatest
        self.bytes = bytes
    }
}
