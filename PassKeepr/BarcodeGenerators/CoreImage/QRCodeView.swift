import CoreImage.CIFilterBuiltins
import SwiftUI

struct QRCodeView: View {
    var data: String
    var correctionLevel: QrCodeCorrectionLevel

    var body: some View {
        if let QRCodeImage = GenerateQRCode(string: data, viewWidth: UIScreen.main.bounds.width, correctionLevel: correctionLevel) {
            GeometryReader { _ in
                Image(uiImage: QRCodeImage)
                    .resizable()
                    .scaledToFit()
            }
            .aspectRatio(1.0, contentMode: .fit)
        }
    }
}

#Preview {
    QRCodeView(data: "Hello, Swift QRcode!", correctionLevel: QrCodeCorrectionLevel.high)
}

func GenerateQRCode(string: String, viewWidth: CGFloat, correctionLevel: QrCodeCorrectionLevel) -> UIImage? {
    let filter = CIFilter.qrCodeGenerator()

    filter.correctionLevel = "\(correctionLevel)"
    filter.message = string.data(using: String.Encoding.ascii)!

    guard let outputImage = filter.outputImage else { return nil }

    let xScale = viewWidth / outputImage.extent.size.width
    let yScale = viewWidth / outputImage.extent.size.height

    let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: xScale, y: yScale))

    // Convert the CIImage to a UIImage
    let context = CIContext()
    if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
        let qrCodeImage = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
        return qrCodeImage
    }

    return nil
}
