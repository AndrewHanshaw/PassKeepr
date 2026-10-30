import CoreImage.CIFilterBuiltins
import PassKeeprCore
import SwiftUI

struct QRCodeView: View {
    var data: String
    var correctionLevel: QrCodeCorrectionLevel
    var encoding: QrCodeEncoding
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        GeometryReader { geometry in
            if let QRCodeImage = GenerateQRCode(string: data, viewWidth: geometry.size.width, correctionLevel: correctionLevel, encoding: encoding, displayScale: displayScale) {
                Image(uiImage: QRCodeImage)
                    .resizable()
                    .scaledToFit()
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
    }
}

#Preview {
    QRCodeView(data: "Hello, Swift QRcode!", correctionLevel: QrCodeCorrectionLevel.high, encoding: QrCodeEncoding.ascii)
}

func GenerateQRCode(string: String, viewWidth: CGFloat, correctionLevel: QrCodeCorrectionLevel, encoding: QrCodeEncoding, displayScale: CGFloat) -> UIImage? {
    let filter = CIFilter.qrCodeGenerator()

    filter.correctionLevel = "\(correctionLevel)"
    filter.message = string.data(using: encoding.toStringEncoding()) ?? Data()

    guard let outputImage = filter.outputImage else { return nil }

    let xScale = viewWidth / outputImage.extent.size.width
    let yScale = viewWidth / outputImage.extent.size.height

    let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: xScale, y: yScale))

    // Convert the CIImage to a UIImage
    let context = CIContext()
    if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
        let qrCodeImage = UIImage(cgImage: cgImage, scale: displayScale, orientation: .up)
        return qrCodeImage
    }

    return nil
}
