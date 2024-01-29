//
//  GenerateBarcode.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 1/27/24.
//

import SwiftUI

func GenerateBarcode(string: String, viewWidth: CGFloat) -> UIImage? {
    // Create a CIFilter named "CICode128BarcodeGenerator"
    guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else { return nil }

    // Set the input message for the barcode
    let data = string.data(using: String.Encoding.ascii)
    filter.setDefaults() // probably not needed?
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
