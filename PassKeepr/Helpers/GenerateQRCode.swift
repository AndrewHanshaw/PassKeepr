//
//  GenerateQRCode.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 1/27/24.
//

import SwiftUI

enum QrCodeCorrectionLevel: Codable, CustomStringConvertible {
    case low
    case medium
    case quartile
    case high

    var description : String {
        switch self {
            case .low: return "L"
            case .medium: return "M"
            case .quartile: return "Q"
            case .high: return "H"
        }
    }
}

func GenerateQRCode(string: String, viewWidth: CGFloat, correctionLevel: QrCodeCorrectionLevel) -> UIImage? {
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }

    // Set the input message for the QR code
    let data = string.data(using: String.Encoding.ascii)
    filter.setValue("\(correctionLevel)", forKey: "inputCorrectionLevel")
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
