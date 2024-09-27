import SwiftUI

struct UPCEView: View {
    @State var ratio: CGFloat
    @Binding var value: String

    var barcodeDataBuffer: Data {
        stringToUPCEBarcodeData(value, paritySequence: 0x15) ?? Data()
    }

    let numberOfSegments: UInt8 = 3 + 42 + 6

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .colorEffect(ShaderLibrary.OneDimensionalBarcodeFilter(.float(geometry.size.width), .data(barcodeDataBuffer), .data(Data([numberOfSegments]))))
        }
        .aspectRatio(ratio, contentMode: .fit)
    }
}

#Preview {
    UPCEView(ratio: 1.0, value: .constant("654321"))
}

import Foundation

func stringToUPCEBarcodeData(_ stringValue: String, paritySequence: UInt8) -> Data? {
    // paritySequence is a 6 bit value, where 0 = even, 1 = odd

    // Ensure the input is a 6-character string or pad with leading zeros
    let paddedString = stringValue.padding(toLength: 6, withPad: "0", startingAt: 0)

    let digitTo7BitEven: [Int: String] = [
        0: "0100111", // 1123
        1: "0110011", // 1222
        2: "0011011", // 2212
        3: "0100001", // 1141
        4: "0011101", // 2311
        5: "0111001", // 1321
        6: "0000101", // 4111
        7: "0010001", // 2131
        8: "0001001", // 3121
        9: "0010111", // 2113
    ]

    let digitTo7BitOdd: [Int: String] = [
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

    // Convert each digit to its 7-bit representation and concatenate
    let binaryString = paddedString.enumerated().compactMap { index, digit in
        guard
            let digitValue = Int(String(digit)),
            let sevenBitDigit = (((paritySequence >> index) & 0x1) != 0) ? digitTo7BitEven[digitValue] : digitTo7BitOdd[digitValue]
        else {
            return nil
        }
        return sevenBitDigit
    }.joined()

    // Append start and end patterns, append 0s so the resulting byte array
    // is exactly the right length, otherwise the encoded string will not fill
    // the bytes correctly. The default behavior when trying to pack bis to shift the value to the right
    // which is not what we want here
    // We ignore these bits when using the Metal filter.
    let prefixedBinaryString = "101" + binaryString + "010101" + "00000000"

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
