//
//  Code128Barcode.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 11/20/23.
//

import SwiftUI

struct Code128BarcodeView: View {
    var data: String

    var body: some View {
        if let code128BarcodeImage = GenerateCode128Barcode(string: data,  viewWidth: UIScreen.main.bounds.width) {
            Image(uiImage: code128BarcodeImage)
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    Code128BarcodeView(data: "Hello, Swift Barcode!")
}

func GenerateCode128Barcode(string: String, viewWidth: CGFloat) -> UIImage? {
    guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else { return nil }

    let data = string.data(using: String.Encoding.ascii)
    filter.setDefaults() // probably not needed?
    filter.setValue(data, forKey: "inputMessage")

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
