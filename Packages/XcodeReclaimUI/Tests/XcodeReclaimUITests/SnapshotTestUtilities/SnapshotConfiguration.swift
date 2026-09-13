import Foundation

struct SnapshotConfiguration {
    let size: CGSize
    let scale: CGFloat

    static let theWidthTheseWereRecordedAt: CGFloat = 720
    static let theHeightTheseWereRecordedAt: CGFloat = 640
    static let onePixelPerPoint: CGFloat = 1

    static func window(size: CGSize = CGSize(width: theWidthTheseWereRecordedAt, height: theHeightTheseWereRecordedAt)) -> SnapshotConfiguration {
        SnapshotConfiguration(size: size, scale: onePixelPerPoint)
    }
}
