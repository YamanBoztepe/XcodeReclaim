import AppKit

enum SnapshotComparison {
    static let channelTolerance = 5
    static let differingPixelTolerance = 200

    private static let channelsPerPixel = 4
    private static let bitsPerChannel = 8

    static func differingPixelCount(between drawn: Data, and stored: Data) -> Int? {
        guard let drawnPixels = pixels(of: drawn), let storedPixels = pixels(of: stored),
            drawnPixels.width == storedPixels.width, drawnPixels.height == storedPixels.height
        else { return nil }

        return stride(from: 0, to: drawnPixels.bytes.count, by: channelsPerPixel).count { pixel in
            (0..<channelsPerPixel).contains { channel in
                abs(Int(drawnPixels.bytes[pixel + channel]) - Int(storedPixels.bytes[pixel + channel])) > channelTolerance
            }
        }
    }

    private static func pixels(of png: Data) -> Pixels? {
        guard let image = NSBitmapImageRep(data: png)?.cgImage else { return nil }

        var bytes = [UInt8](repeating: 0, count: image.width * image.height * channelsPerPixel)
        let isDrawn = bytes.withUnsafeMutableBytes { buffer in
            guard
                let context = CGContext(
                    data: buffer.baseAddress,
                    width: image.width,
                    height: image.height,
                    bitsPerComponent: bitsPerChannel,
                    bytesPerRow: image.width * channelsPerPixel,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            else { return false }

            context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
            return true
        }

        return isDrawn ? Pixels(width: image.width, height: image.height, bytes: bytes) : nil
    }
}

private struct Pixels {
    let width: Int
    let height: Int
    let bytes: [UInt8]
}
