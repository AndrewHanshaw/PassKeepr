//
//  QRCodeView.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 11/22/23.
//

import SwiftUI

struct QRCodeView: View {
    var body: some View {
        let QRCodeData = "Hello, Swift QRcode!"

        // Generates a 2D QR code image
        if let QRCodeImage = generateQRCode(from: QRCodeData, withViewWidth: UIScreen.main.bounds.width, with: "H") {
            // Display the generated barcode image
            Image(uiImage: QRCodeImage)
                .resizable()
                .scaledToFit()
        }
    }
}

func generateQRCode(from string: String, withViewWidth viewWidth: CGFloat, with inputCorrectionLevel: String) -> UIImage? {
    // Create a CIFilter named "CICode128BarcodeGenerator"
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }

    // Set the input message for the barcode
    let data = string.data(using: String.Encoding.ascii)
    filter.setValue(inputCorrectionLevel, forKey: "inputCorrectionLevel")
    filter.setValue(data, forKey: "inputMessage")

    // Get the output image from the filter
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

#Preview {
    QRCodeView()
}
