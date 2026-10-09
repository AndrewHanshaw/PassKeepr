import SwiftUI

struct Code39FullASCIIChecksumView: View {
    @Binding var value: String
    var border: Double

    var encodedValue: String {
        let fullASCII = encodeFullASCII(value) ?? ""
        guard let checksum = code39ChecksumChar(for: fullASCII) else { return fullASCII }
        return fullASCII + String(checksum)
    }

    var barcodeDataBuffer: Data {
        stringToCode39BarcodeData(encodedValue) ?? Data()
    }

    var numberOfSegments: Int {
        min((encodedValue.count * 13) + 27, 255)
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
    Code39FullASCIIChecksumView(value: .constant("Hello, World!"), border: 20)
}
