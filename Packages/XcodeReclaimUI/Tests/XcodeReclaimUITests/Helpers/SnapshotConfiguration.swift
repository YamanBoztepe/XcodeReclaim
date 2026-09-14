import Foundation

struct SnapshotConfiguration {
    let size: CGSize
    let scale: CGFloat

    static let recordedWidth: CGFloat = 720
    static let recordedHeight: CGFloat = 640
    static let onePixelPerPoint: CGFloat = 1

    static func window(size: CGSize = CGSize(width: recordedWidth, height: recordedHeight)) -> SnapshotConfiguration {
        SnapshotConfiguration(size: size, scale: onePixelPerPoint)
    }
}
