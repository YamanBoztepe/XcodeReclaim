import AppKit
import SwiftUI
import Testing

extension View {
    @MainActor func verify(
        named name: String,
        configuration: SnapshotConfiguration = .window(),
        record: Bool = false,
        filePath: StaticString = #filePath,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        guard SnapshotEnvironment.isTheRecordingMachine(sourceLocation: sourceLocation) else { return }
        guard let drawn = drawn(configuration) else {
            Issue.record("The view drew nothing that could be turned into a PNG.", sourceLocation: sourceLocation)
            return
        }

        verify(drawn, named: name, record: record, filePath: filePath, sourceLocation: sourceLocation)
    }

    @MainActor private func drawn(_ configuration: SnapshotConfiguration) -> Data? {
        let shown = NSHostingView(rootView: frame(width: configuration.size.width, height: configuration.size.height))
        shown.frame = CGRect(origin: .zero, size: configuration.size)
        shown.appearance = NSAppearance(named: .aqua)

        let window = SnapshotWindow(size: configuration.size, scale: configuration.scale)
        window.contentView = shown
        shown.layoutSubtreeIfNeeded()
        settle(shown)
        window.displayIfNeeded()

        let bitsPerSample = 8
        let redGreenBlueAndAlpha = 4
        let workedOutFromTheRest = 0
        guard
            let pixels = NSBitmapImageRep(
                bitmapDataPlanes: nil,
                pixelsWide: Int(configuration.size.width * configuration.scale),
                pixelsHigh: Int(configuration.size.height * configuration.scale),
                bitsPerSample: bitsPerSample,
                samplesPerPixel: redGreenBlueAndAlpha,
                hasAlpha: true,
                isPlanar: false,
                colorSpaceName: .deviceRGB,
                bytesPerRow: workedOutFromTheRest,
                bitsPerPixel: workedOutFromTheRest)
        else { return nil }

        shown.cacheDisplay(in: shown.bounds, to: pixels)
        return pixels.representation(using: .png, properties: [:])
    }

    @MainActor private func settle(_ shown: NSView) {
        let turnsBeforeTheTableHasItsRows = 50

        for _ in 0..<turnsBeforeTheTableHasItsRows {
            RunLoop.current.run(mode: .default, before: .distantPast)
            shown.layoutSubtreeIfNeeded()
        }
        hideTheScrollers(in: shown)
    }

    @MainActor private func hideTheScrollers(in view: NSView) {
        if let scrolling = view as? NSScrollView {
            scrolling.hasVerticalScroller = false
            scrolling.hasHorizontalScroller = false
            scrolling.verticalScroller?.alphaValue = 0
            scrolling.horizontalScroller?.alphaValue = 0
        }
        for subview in view.subviews {
            hideTheScrollers(in: subview)
        }
    }

    private func verify(_ drawn: Data, named name: String, record: Bool, filePath: StaticString, sourceLocation: SourceLocation) {
        let recorded = recordedSnapshot(named: name, beside: filePath)
        guard !record else {
            save(drawn, to: recorded, sourceLocation: sourceLocation)
            Issue.record("The snapshot was recorded. Take `record: true` off to verify against it.", sourceLocation: sourceLocation)
            return
        }

        guard let stored = try? Data(contentsOf: recorded) else {
            save(drawn, to: recorded, sourceLocation: sourceLocation)
            Issue.record("No snapshot was recorded for \(name). One has been written; look at it and run again.", sourceLocation: sourceLocation)
            return
        }

        guard drawn != stored else { return }

        Attachment.record(Attachment([UInt8](drawn), named: "1_drawn_now.png"))
        Attachment.record(Attachment([UInt8](stored), named: "2_recorded_before.png"))
        Issue.record("\(name) does not match the snapshot recorded at \(recorded.path(percentEncoded: false)).", sourceLocation: sourceLocation)
    }

    private func recordedSnapshot(named name: String, beside filePath: StaticString) -> URL {
        URL(fileURLWithPath: String(describing: filePath))
            .deletingLastPathComponent()
            .appending(path: "snapshots")
            .appending(path: "\(name).png")
    }

    private func save(_ drawn: Data, to recorded: URL, sourceLocation: SourceLocation) {
        do {
            try FileManager.default.createDirectory(at: recorded.deletingLastPathComponent(), withIntermediateDirectories: true)
            try drawn.write(to: recorded)
        } catch {
            Issue.record("The snapshot could not be written: \(error)", sourceLocation: sourceLocation)
        }
    }
}
