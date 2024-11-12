import UIKit

extension UIImage {
    func resizeToFit(maxWidth: CGFloat = 480, maxHeight: CGFloat = 150) -> UIImage {
        let originalWidth = size.width
        let originalHeight = size.height

        // Calculate scaling factors
        let widthRatio = maxWidth / originalWidth
        let heightRatio = maxHeight / originalHeight

        // Use the smaller ratio to ensure image fits within bounds
        let scale = min(widthRatio, heightRatio)

        // Calculate new size while maintaining aspect ratio
        let newWidth = originalWidth * scale
        let newHeight = originalHeight * scale
        let newSize = CGSize(width: newWidth, height: newHeight)

        // Create the rect to draw in
        let rect = CGRect(origin: .zero, size: newSize)

        // Configure the rendering
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        defer { UIGraphicsEndImageContext() }

        // Draw the image
        draw(in: rect)

        // Get the resized image
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return self
        }

        return resizedImage
    }

    // Resizes the image to the dimensions as defined by targetSize. The image will be stretched as needed to meet these dimensions exactly
    func resize(targetSize: CGSize) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
    let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
    self.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage!
}
}
