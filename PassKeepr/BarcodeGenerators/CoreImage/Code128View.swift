import CoreImage.CIFilterBuiltins
import SwiftUI

struct Code128View: View {
    @Binding var data: String

    var body: some View {
        if let code128BarcodeImage = GenerateCode128Barcode(string: data, viewWidth: UIScreen.main.bounds.width) {
            GeometryReader { geometry in
                Image(uiImage: code128BarcodeImage)
                    .resizable()
                    .frame(width: geometry.size.width)
            }
        }
    }
}

#Preview {
    Code128View(data: .constant("Hello, Swift Barcode!"))
}

func GenerateCode128Barcode(string: String, viewWidth: CGFloat) -> UIImage? {
    let filter = CIFilter.code128BarcodeGenerator()

    filter.quietSpace = 4
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
