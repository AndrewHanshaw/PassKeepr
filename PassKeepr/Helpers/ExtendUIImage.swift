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

    func resizeToFit2(maxWidth: CGFloat = 480, maxHeight: CGFloat = 150) -> UIImage {
        let originalWidth = size.width
        let originalHeight = size.height

        // Calculate scaling factors
        let widthRatio = maxWidth / originalWidth
        let heightRatio = maxHeight / originalHeight

        // Use the smaller ratio to ensure image fits within bounds
        let scale = max(widthRatio, heightRatio)

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
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }

    // Calculate brightness from the average color
    func averageBrightness() -> CGFloat? {
        guard let avgColor = averageColor else { return nil }

        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        avgColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (0.299 * red) + (0.587 * green) + (0.114 * blue)
    }
}
