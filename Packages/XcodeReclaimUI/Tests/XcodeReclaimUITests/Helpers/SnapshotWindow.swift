import AppKit

final class SnapshotWindow: NSWindow {
    private let scale: CGFloat

    init(size: CGSize, scale: CGFloat) {
        self.scale = scale
        super.init(contentRect: CGRect(origin: .zero, size: size), styleMask: [.borderless], backing: .buffered, defer: true)
        colorSpace = .sRGB
    }

    override var backingScaleFactor: CGFloat {
        scale
    }
}
