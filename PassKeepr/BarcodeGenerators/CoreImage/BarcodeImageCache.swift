import CoreImage
import UIKit

// Shared cache for the CoreImage barcode generators
enum BarcodeImageCache {
    static let context = CIContext()
    static let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        // Barcode images are cached at display-pixel size, and edit screens regenerate one per edit
        // Bound the total decoded bytes so those can't pile up between memory warnings.
        cache.totalCostLimit = 32 * 1024 * 1024
        return cache
    }()

    static func cachedImage(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    static func store(_ image: UIImage, forKey key: String) {
        let cost = image.cgImage.map { $0.bytesPerRow * $0.height } ?? 0
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }
}
