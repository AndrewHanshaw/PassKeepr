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

    // Draws self into a fixed-size RGBA8 (premultipliedLast) buffer and returns the raw pixels.
    // The image is scaled to fit within maxDimension to keep the per-pixel scans cheap.
    private func rgbaPixels(maxDimension: Int = 50) -> (pixels: [UInt8], width: Int, height: Int)? {
        guard let cgImage = cgImage else { return nil }

        let srcW = cgImage.width
        let srcH = cgImage.height
        guard srcW > 0, srcH > 0 else { return nil }

        let scale = min(1.0, CGFloat(maxDimension) / CGFloat(max(srcW, srcH)))
        let width = max(1, Int((CGFloat(srcW) * scale).rounded()))
        let height = max(1, Int((CGFloat(srcH) * scale).rounded()))

        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return (pixels, width, height)
    }

    // Quantizes a colour to a 5-bits-per-channel bucket key so similar shades group together
    private static func bucketKey(r: UInt8, g: UInt8, b: UInt8) -> Int {
        (Int(r) >> 3) << 10 | (Int(g) >> 3) << 5 | (Int(b) >> 3)
    }

    private static func color(fromBucketKey key: Int) -> UIColor {
        // Reconstruct the colour from the centre of each 5-bit bucket
        let r = ((key >> 10) & 0x1F) << 3 | 0x04
        let g = ((key >> 5) & 0x1F) << 3 | 0x04
        let b = (key & 0x1F) << 3 | 0x04
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1)
    }

    // Most common colours of the left-most and right-most columns of the image. Voting only over the
    // vertical sides (rather than the whole outer ring) avoids being dominated by white top/bottom
    // margins — these are exactly the edges that get extended when padding the logo's width.
    // `isOpaque` reports whether those side columns are mostly opaque.
    func sideEdgeColors() -> (left: UIColor, right: UIColor, isOpaque: Bool)? {
        guard let (pixels, width, height) = rgbaPixels() else { return nil }

        func modalColor(xRange: Range<Int>) -> (color: UIColor?, opaque: Int, total: Int) {
            var histogram: [Int: Int] = [:]
            var opaque = 0
            var total = 0
            for x in xRange {
                for y in 0 ..< height {
                    let i = (width * y + x) * 4
                    total += 1
                    if pixels[i + 3] < 128 { continue }
                    opaque += 1
                    histogram[UIImage.bucketKey(r: pixels[i], g: pixels[i + 1], b: pixels[i + 2]), default: 0] += 1
                }
            }
            return (histogram.max(by: { $0.value < $1.value }).map { UIImage.color(fromBucketKey: $0.key) }, opaque, total)
        }

        let band = max(1, width / 10) // sample the outer ~10% of columns on each side for robustness
        let left = modalColor(xRange: 0 ..< band)
        let right = modalColor(xRange: (width - band) ..< width)

        guard let leftColor = left.color, let rightColor = right.color else { return nil }
        let totalSamples = left.total + right.total
        let isOpaque = totalSamples > 0 && Double(left.opaque + right.opaque) / Double(totalSamples) > 0.75
        return (leftColor, rightColor, isOpaque)
    }

    // Pads the image out to the given width/height aspect ratio by adding bars on the left and
    // right, centering the original. This lets a square or tall logo fit fully inside the wider
    // logo crop rectangle instead of having its top/bottom cropped off. Each bar is filled with the
    // colour of the side it extends, so the bars blend into the logo's actual edges. Returns self
    // unchanged if the image is already wide enough.
    func paddedToAspectRatio(_ aspectRatio: CGFloat, leftFill: UIColor, rightFill: UIColor) -> UIImage {
        let w = size.width
        let h = size.height
        guard w > 0, h > 0, aspectRatio > 0, w / h < aspectRatio else { return self }

        let canvas = CGSize(width: h * aspectRatio, height: h)
        let barWidth = (canvas.width - w) / 2
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        format.scale = scale

        let renderer = UIGraphicsImageRenderer(size: canvas, format: format)
        return renderer.image { ctx in
            // Overlap each bar 1pt under the image to avoid a hairline gap from rounding
            leftFill.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: barWidth + 1, height: canvas.height))
            rightFill.setFill()
            ctx.fill(CGRect(x: canvas.width - barWidth - 1, y: 0, width: barWidth + 1, height: canvas.height))
            draw(in: CGRect(x: barWidth, y: 0, width: w, height: h))
        }
    }
}
