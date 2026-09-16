import AppKit

final class SnapshotWindow: NSWindow {
    init(size: CGSize) {
        super.init(contentRect: CGRect(origin: .zero, size: size), styleMask: [.borderless], backing: .buffered, defer: true)
        colorSpace = .sRGB
    }

    override var backingScaleFactor: CGFloat {
        SnapshotDisplay.retinaScale
    }
}
