import CoreImage.CIFilterBuiltins
import SwiftUI

struct PDF417View: View {
    var data: String
    var targetWidth: CGFloat = 400
    var targetHeight: CGFloat = 133
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        if let PDF417Image = GeneratePDF417Barcode(string: data, viewWidth: targetWidth, viewHeight: targetHeight, displayScale: displayScale) {
            Image(uiImage: PDF417Image)
                .resizable()
                // Fill whatever space the parent offers, in both axes
                // targetWidth/targetHeight only set the generated image's resolution (not the layout size)
                // so the default image is safe in callers that don't know their exact size (edit/picker previews)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    PDF417View(data: "Hello, Swift PDF417 Barcode!")
}

func GeneratePDF417Barcode(string: String, viewWidth: CGFloat, viewHeight: CGFloat, displayScale: CGFloat) -> UIImage? {
    let pixelWidth = max(1, Int((viewWidth * displayScale).rounded()))
    let pixelHeight = max(1, Int((viewHeight * displayScale).rounded()))
    let cacheKey = "pdf417|\(string)|\(pixelWidth)x\(pixelHeight)"
    if let cached = BarcodeImageCache.cachedImage(forKey: cacheKey) {
        return cached
    }

    let filter = CIFilter.pdf417BarcodeGenerator()

    filter.message = string.data(using: String.Encoding.ascii) ?? "invalid data".data(using: String.Encoding.ascii)!

    guard let outputImage = filter.outputImage else { return nil }

    let xScale = CGFloat(pixelWidth) / outputImage.extent.size.width
    let yScale = CGFloat(pixelHeight) / outputImage.extent.size.height

    let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: xScale, y: yScale))

    // Convert the CIImage to a UIImage, using the shared context
    if let cgImage = SharedCIContext.context.createCGImage(scaledImage, from: scaledImage.extent) {
        let pdf417Image = UIImage(cgImage: cgImage, scale: displayScale, orientation: .up)
        BarcodeImageCache.store(pdf417Image, forKey: cacheKey)
        return pdf417Image
    }

    return nil
}
