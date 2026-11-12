import CoreImage.CIFilterBuiltins
import SwiftUI

struct Code128View: View {
    var data: String
    var targetWidth: CGFloat = 400
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        if let code128BarcodeImage = GenerateCode128Barcode(string: data, viewWidth: targetWidth, displayScale: displayScale) {
            Image(uiImage: code128BarcodeImage)
                .resizable()
                // Fill whatever space the parent offers, in both axes. The bars are uniform vertically, so stretching the height is lossless.
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    Code128View(data: "Hello, Swift Barcode!")
}

func GenerateCode128Barcode(string: String, viewWidth: CGFloat, displayScale: CGFloat) -> UIImage? {
    let pixelWidth = max(1, Int((viewWidth * displayScale).rounded()))
    let cacheKey = "code128|\(string)|\(pixelWidth)"
    if let cached = BarcodeImageCache.cachedImage(forKey: cacheKey) {
        return cached
    }

    let filter = CIFilter.code128BarcodeGenerator()

    filter.quietSpace = 4
    filter.message = string.data(using: String.Encoding.ascii)!

    guard let outputImage = filter.outputImage else { return nil }

    // Non-uniform scale: width to the target pixel width, height to a 3:1
    // image (matching the grid's barcode container). The image is stretched
    // to fit its container by SwiftUI, so only the bar height is affected.
    let xScale = CGFloat(pixelWidth) / outputImage.extent.size.width
    let yScale = (CGFloat(pixelWidth) / 3) / outputImage.extent.size.height
    let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: xScale, y: yScale))

    // Convert the CIImage to a UIImage, using the shared context
    if let cgImage = BarcodeImageCache.context.createCGImage(scaledImage, from: scaledImage.extent) {
        let code128Image = UIImage(cgImage: cgImage, scale: displayScale, orientation: .up)
        BarcodeImageCache.store(code128Image, forKey: cacheKey)
        return code128Image
    }

    return nil
}
