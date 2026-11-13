import CoreImage.CIFilterBuiltins
import PassKeeprCore
import SwiftUI

struct QRCodeView: View {
    var data: String
    var correctionLevel: QrCodeCorrectionLevel
    var encoding: QrCodeEncoding
    // Width the QR code will be displayed at
    // The grid passes its exact width (60pt)
    // other callers use the default image SwiftUI scales down
    var targetWidth: CGFloat = 400
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        if let QRCodeImage = GenerateQRCode(string: data, viewWidth: targetWidth, correctionLevel: correctionLevel, encoding: encoding, displayScale: displayScale) {
            Image(uiImage: QRCodeImage)
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    QRCodeView(data: "Hello, Swift QRcode!", correctionLevel: QrCodeCorrectionLevel.high, encoding: QrCodeEncoding.ascii)
}

func GenerateQRCode(string: String, viewWidth: CGFloat, correctionLevel: QrCodeCorrectionLevel, encoding: QrCodeEncoding, displayScale: CGFloat) -> UIImage? {
    // Render at display pixels, not points, so the image is crisp at its displayed size without SwiftUI having to upscale a 1x render.
    let pixelWidth = max(1, Int((viewWidth * displayScale).rounded()))
    let cacheKey = "qr|\(string)|\(correctionLevel)|\(encoding)|\(pixelWidth)"
    if let cached = BarcodeImageCache.cachedImage(forKey: cacheKey) {
        return cached
    }

    let filter = CIFilter.qrCodeGenerator()

    filter.correctionLevel = "\(correctionLevel)"
    filter.message = string.data(using: encoding.toStringEncoding()) ?? Data()

    guard let outputImage = filter.outputImage else { return nil }

    let scale = CGFloat(pixelWidth) / outputImage.extent.size.width
    let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

    // Convert the CIImage to a UIImage, using the shared context
    if let cgImage = SharedCIContext.context.createCGImage(scaledImage, from: scaledImage.extent) {
        let qrCodeImage = UIImage(cgImage: cgImage, scale: displayScale, orientation: .up)
        BarcodeImageCache.store(qrCodeImage, forKey: cacheKey)
        return qrCodeImage
    }

    return nil
}
