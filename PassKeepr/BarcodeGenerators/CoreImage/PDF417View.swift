import CoreImage.CIFilterBuiltins
import SwiftUI

struct PDF417View: View {
    var data: String

    var body: some View {
        if let PDF417Image = GeneratePDF417Barcode(string: data, viewWidth: UIScreen.main.bounds.width, viewHeight: UIScreen.main.bounds.height) {
            GeometryReader { geometry in
                Image(uiImage: PDF417Image)
                    .resizable()
                    .frame(width: geometry.size.width)
            }
        }
    }
}

#Preview {
    PDF417View(data: "Hello, Swift PDF417 Barcode!")
}

func GeneratePDF417Barcode(string: String, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage? {
    let filter = CIFilter.pdf417BarcodeGenerator()

    filter.message = string.data(using: String.Encoding.ascii) ?? "invalid data".data(using: String.Encoding.ascii)!

    guard let outputImage = filter.outputImage else { return nil }

    let xScale = viewWidth / outputImage.extent.size.width
    let yScale = viewHeight / outputImage.extent.size.height

    let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: xScale, y: yScale))

    // Convert the CIImage to a UIImage
    let context = CIContext()
    if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
        let qrCodeImage = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
        return qrCodeImage
    }

    return nil
}
