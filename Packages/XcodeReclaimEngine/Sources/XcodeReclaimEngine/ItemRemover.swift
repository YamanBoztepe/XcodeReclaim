import Foundation

public protocol ItemRemover {
    func removeItem(at url: URL) throws -> Bool
}
