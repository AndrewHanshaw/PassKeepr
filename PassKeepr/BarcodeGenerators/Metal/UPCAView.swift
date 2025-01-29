import SwiftUI

struct UPCAView: View {
    @Binding var value: String
    var border: Double

    var barcodeDataBuffer: Data {
        stringToUPCABarcodeData(value) ?? Data()
    }

    let numberOfSegments: UInt8 = 3 + 42 + 5 + 42 + 3

    var body: some View {
        GeometryReader { geometry in
            let borderWidth = geometry.size.width * border
            Rectangle()
                .colorEffect(ShaderLibrary.OneDimensionalBarcodeFilter(.float(geometry.size.width - CGFloat(borderWidth * 2)), .data(barcodeDataBuffer), .data(Data([numberOfSegments]))))
                .padding(CGFloat(borderWidth))
                .background(Color.white)
        }
    }
}

#Preview {
    UPCAView(value: .constant("654321123456"), border: 20)
}

import Foundation

func stringToUPCABarcodeData(_ stringValue: String) -> Data? {
    // Ensure the input is a 12-character string or pad with leading zeros
    let paddedString = stringValue.padding(toLength: 12, withPad: "0", startingAt: 0)

    let digitTo7BitLeft: [Int: String] = [
        0: "0001101", // 3211
        1: "0011001", // 2221
        2: "0010011", // 2122
        3: "0111101", // 1411
        4: "0100011", // 1132
        5: "0110001", // 1231
        6: "0101111", // 1114
        7: "0111011", // 1312
        8: "0110111", // 1213
        9: "0001011", // 3112
    ]

    let digitTo7BitRight: [Int: String] = [
        0: "1110010", // 3211
        1: "1100110", // 2221
        2: "1101100", // 2122
        3: "1000010", // 1411
        4: "1011100", // 1132
        5: "1001110", // 1321
        6: "1010000", // 1114
        7: "1000100", // 1312
        8: "1001000", // 1213
        9: "1110100", // 3112
    ]

    // Convert each digit to its 7-bit representation and concatenate
    let binaryString = paddedString.enumerated().compactMap { index, digit in
        guard
            let digitValue = Int(String(digit))
        else {
            return nil
        }

        let sevenBitDigit = (index < 6) ? digitTo7BitLeft[digitValue] : digitTo7BitRight[digitValue]
        return sevenBitDigit
    }.joined()

    // Append start and end patterns, append 0s so the resulting byte array
    // is exactly the right length, otherwise the encoded string will not fill
    // the bytes correctly. The default behavior when trying to pack bis to shift the value to the right
    // which is not what we want here
    // We ignore these bits when using the Metal filter.
    let prefixedBinaryString = "101" + String(binaryString.prefix(42)) + "01010" + String(binaryString.suffix(42)) + "101" + "00000000"

    var byteArray: [UInt8] = []
    var index = prefixedBinaryString.startIndex

    while index < prefixedBinaryString.endIndex {
        let endIndex = prefixedBinaryString.index(index, offsetBy: 8, limitedBy: prefixedBinaryString.endIndex) ?? prefixedBinaryString.endIndex
        let byteString = prefixedBinaryString[index ..< endIndex]

        if let byte = UInt8(byteString, radix: 2) {
            byteArray.append(byte)
        } else {
            print("Invalid binary string.")
            break
        }

        index = endIndex
    }

    return Data(byteArray)
}
