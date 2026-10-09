import SwiftUI

struct Code39ChecksumView: View {
    @Binding var value: String
    var border: Double

    var barcodeDataBuffer: Data {
        stringToCode39ChecksumBarcodeData(value.uppercased()) ?? Data()
    }

    var numberOfSegments: Int {
        min((value.count * 13) + 27 + 13, 255)
    }

    var body: some View {
        GeometryReader { geometry in
            let borderWidth = geometry.size.width * border
            Rectangle()
                .colorEffect(ShaderLibrary.OneDimensionalBarcodeFilter(.float(geometry.size.width - CGFloat(borderWidth * 2)), .data(barcodeDataBuffer), .data(Data([UInt8(numberOfSegments)]))))
                .padding(CGFloat(borderWidth))
                .background(Color.white)
        }
    }
}

#Preview {
    Code39ChecksumView(value: .constant("WIKIPEDIA"), border: 20)
}

import Foundation

func stringToCode39ChecksumBarcodeData(_ stringValue: String) -> Data? {
    guard let checksum = code39ChecksumChar(for: stringValue) else { return nil }
    return stringToCode39BarcodeData(stringValue + String(checksum))
}
