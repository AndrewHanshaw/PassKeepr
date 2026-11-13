import CoreImage
import UIKit

// Pre-rendered background-photo images for the scrolling pass grid.

enum PassBackgroundImageCache {
    static let blurRadius: CGFloat = 6

    private static let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.totalCostLimit = 64 * 1024 * 1024
        return cache
    }()

    private static func store(_ image: UIImage, forKey key: NSString) {
        // Cost is the decoded bitmap size in bytes.
        let cost = image.cgImage.map { $0.bytesPerRow * $0.height } ?? 0
        cache.setObject(image, forKey: key, cost: cost)
    }

    private static func key(id: UUID, dataCount: Int, pixelSize: CGSize) -> NSString {
        "\(id.uuidString)|\(dataCount)|\(Int(pixelSize.width))x\(Int(pixelSize.height))" as NSString
    }

    static func cachedImage(id: UUID, dataCount: Int, pixelSize: CGSize) -> UIImage? {
        cache.object(forKey: key(id: id, dataCount: dataCount, pixelSize: pixelSize))
    }

    // Generates (and caches) the blurred image. Safe to call off the main thread. Returns nil if the data can't be decoded.
    @discardableResult
    static func generate(id: UUID, data: Data, pixelSize: CGSize, displayScale: CGFloat) -> UIImage? {
        guard pixelSize.width >= 1, pixelSize.height >= 1 else { return nil }

        // ImageIO thumbnail: decodes at the target size without ever decoding the full photo.
        guard let sharp = decodedImage(from: data, maxPixelSize: max(pixelSize.width, pixelSize.height)),
              let sharpCG = sharp.cgImage
        else { return nil }

        // The card stretches the photo to its frame (.resizable() without an aspect ratio), so bake the blur at the stretched size.
        let source = CIImage(cgImage: sharpCG)
        let stretched = source.transformed(by: CGAffineTransform(
            scaleX: pixelSize.width / source.extent.width,
            y: pixelSize.height / source.extent.height
        ))
        let extent = CGRect(origin: .zero, size: pixelSize)

        // clampedToExtent so the blur samples edge pixels instead of transparent black; avoids a faded rim around the photo.
        let blurredCI = stretched
            .clampedToExtent()
            .applyingGaussianBlur(sigma: Double(blurRadius * displayScale))
            .cropped(to: extent)

        guard let blurredCG = SharedCIContext.context.createCGImage(blurredCI, from: extent) else { return nil }
        let blurred = UIImage(cgImage: blurredCG, scale: displayScale, orientation: .up)

        store(blurred, forKey: key(id: id, dataCount: data.count, pixelSize: pixelSize))
        return blurred
    }
}
