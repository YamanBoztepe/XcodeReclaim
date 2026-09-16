import XcodeReclaimEngine

final class XcodeCopyLoaderStub: XcodeCopyLoader {
    var reported: [XcodeCopy] = []

    func load() -> [XcodeCopy] {
        reported
    }
}
