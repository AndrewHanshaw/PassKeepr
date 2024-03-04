//
//  PDF417View.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 03/03/24.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct PDF417View: View {
    @State var ratio: CGFloat
    @Binding var data: String

    var body: some View {
        if let PDF417Image = GeneratePDF417Barcode(string: data,  viewWidth: UIScreen.main.bounds.width, viewHeight: UIScreen.main.bounds.height) {
            GeometryReader { geometry in
                Image(uiImage: PDF417Image)
                    .resizable()
                    .frame(width:geometry.size.width)
            }
            .aspectRatio(ratio, contentMode: .fit)
        }
    }
}

#Preview {
    PDF417View(ratio: 2.5, data: .constant("Hello, Swift PDF417 Barcode!"))
}

func GeneratePDF417Barcode(string: String, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage? {
    let filter = CIFilter.pdf417BarcodeGenerator()

    filter.message = string.data(using: String.Encoding.ascii)!
//    filter.preferredAspectRatio = Float(viewWidth/viewHeight)

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
