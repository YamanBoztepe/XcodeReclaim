import XcodeReclaimCore

public protocol LeftoverSource {
    func leftovers(announcing announce: (String) -> Void) -> [Leftover]
}
