import Foundation

public protocol RemovalChecker {
    func canRemoveItem(at url: URL) -> Bool
}
