import XcodeReclaimEngine

final class XcodeCopiesStub: XcodeCopies {
    var reported: [XcodeCopy] = []

    func copies() -> [XcodeCopy] {
        reported
    }
}
