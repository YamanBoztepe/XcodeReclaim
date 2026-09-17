import XcodeReclaimCore

extension Deletion {
    var isFailure: Bool {
        guard case .failed = self else { return false }

        return true
    }
}
