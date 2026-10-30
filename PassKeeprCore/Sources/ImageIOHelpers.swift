import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Platform-independent image helpers built on ImageIO/CoreGraphics, so pass generation and
/// brightness calculation don't depend on UIKit and can be unit tested on macOS.
enum ImageIOHelpers {
    static func decode(_ data: Data) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }

    private static func makeContext(width: Int, height: Int) -> CGContext? {
        CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
    }

    /// Stretches the image to exactly `width` x `height` pixels and encodes it as PNG.
    static func resizedPNGData(from image: CGImage, width: Int, height: Int) -> Data? {
        guard width > 0, height > 0, let context = makeContext(width: width, height: height) else { return nil }
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let resized = context.makeImage() else { return nil }

        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output, UTType.png.identifier as CFString, 1, nil) else { return nil }
        CGImageDestinationAddImage(destination, resized, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return output as Data
    }

    /// Perceived brightness (0...1) of the image's average color, computed on a copy scaled to fit within `maxWidth` x `maxHeight`.
    static func averageBrightness(of image: CGImage, maxWidth: Int, maxHeight: Int) -> Double? {
        let scale = min(Double(maxWidth) / Double(image.width), Double(maxHeight) / Double(image.height))
        let width = max(1, Int((Double(image.width) * scale).rounded()))
        let height = max(1, Int((Double(image.height) * scale).rounded()))
        guard let context = makeContext(width: width, height: height) else { return nil }
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let pixels = context.data?.assumingMemoryBound(to: UInt8.self) else { return nil }

        let bytesPerRow = context.bytesPerRow
        var red = 0.0, green = 0.0, blue = 0.0
        for y in 0 ..< height {
            for x in 0 ..< width {
                let offset = y * bytesPerRow + x * 4
                red += Double(pixels[offset])
                green += Double(pixels[offset + 1])
                blue += Double(pixels[offset + 2])
            }
        }
        let count = Double(width * height) * 255.0
        return (0.299 * red / count) + (0.587 * green / count) + (0.114 * blue / count)
    }
}
