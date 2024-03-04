//
//  AztecView.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 03/03/24.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct AztecView: View {
    @Binding var data: String
    @Binding var numberOfLayers: Int
    @Binding var isCompact: Bool
    @Binding var percentCorrectionLevel: Int

    var body: some View {
        if let AztecImage = GenerateAztecBarcode(string: data,  viewWidth: UIScreen.main.bounds.width, numberOfLayers: numberOfLayers, isCompact: isCompact, percentCorrectionLevel: percentCorrectionLevel) {
            GeometryReader { geometry in
                Image(uiImage: AztecImage)
                    .resizable()
                    .frame(width:geometry.size.width)
            }
            .aspectRatio(1.0, contentMode: .fit)
        }
    }
}

#Preview {
    AztecView(data: .constant("Hello, Swift Aztec Barcode!"), numberOfLayers: .constant(3), isCompact: .constant(false), percentCorrectionLevel: .constant(50))
}

func GenerateAztecBarcode(string: String, viewWidth: CGFloat, numberOfLayers: Int, isCompact: Bool, percentCorrectionLevel: Int) -> UIImage? {
    let filter = CIFilter.aztecCodeGenerator()

    filter.message = string.data(using: String.Encoding.ascii)!
    filter.layers = Float(numberOfLayers)
    filter.compactStyle = isCompact ? 1.0 : 0.0
    filter.correctionLevel = Float(percentCorrectionLevel)

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
