import ImageIO
import UIKit

// Decodes image data scaled down to `maxPixelSize` on its longest side, in device pixels.
// ImageIO builds the thumbnail without decoding the full image first
// so a large photo used as a strip or logo costs a fraction of a full `UIImage(data:)` decode
// the result is small enough to hold in a per-view cache while scrolling
// Images smaller than the target are returned at their natural size (not upscaled)
// Returns nil for empty or undecodable data, or a non-positive target size.
func decodedImage(from data: Data, maxPixelSize: CGFloat) -> UIImage? {
    guard !data.isEmpty, maxPixelSize > 0 else { return nil }
    guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
    let options: [CFString: Any] = [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceThumbnailMaxPixelSize: Int(maxPixelSize.rounded()),
    ]
    guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
    return UIImage(cgImage: cgImage)
}
