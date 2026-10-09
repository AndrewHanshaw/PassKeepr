import SwiftUI

struct EAN8View: View {
    @Binding var value: String
    var border: Double

    var barcodeDataBuffer: Data {
        stringToEAN8BarcodeData(value) ?? Data()
    }

    /// 3 (start) + 28 (left) + 5 (middle) + 28 (right) + 3 (end)
    let numberOfSegments: UInt8 = 3 + 28 + 5 + 28 + 3

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
    EAN8View(value: .constant("96385074"), border: 20)
}

import Foundation

func stringToEAN8BarcodeData(_ stringValue: String) -> Data? {
    guard stringValue.count == 8, stringValue.allSatisfy({ $0.isNumber }) else {
        return nil
    }

    let digitTo7BitLeftOdd: [Int: String] = [
        0: "0001101",
        1: "0011001",
        2: "0010011",
        3: "0111101",
        4: "0100011",
        5: "0110001",
        6: "0101111",
        7: "0111011",
        8: "0110111",
        9: "0001011",
    ]

    let digitTo7BitRight: [Int: String] = [
        0: "1110010",
        1: "1100110",
        2: "1101100",
        3: "1000010",
        4: "1011100",
        5: "1001110",
        6: "1010000",
        7: "1000100",
        8: "1001000",
        9: "1110100",
    ]

    let leftDigits = stringValue.prefix(4)
    let leftBinaryString = leftDigits.compactMap { digit -> String? in
        guard let digitValue = Int(String(digit)) else { return nil }
        return digitTo7BitLeftOdd[digitValue]
    }.joined()

    let rightDigits = stringValue.suffix(4)
    let rightBinaryString = rightDigits.compactMap { digit -> String? in
        guard let digitValue = Int(String(digit)) else { return nil }
        return digitTo7BitRight[digitValue]
    }.joined()

    let prefixedBinaryString = "101" + leftBinaryString + "01010" + rightBinaryString + "101" + "00000"

    var byteArray: [UInt8] = []
    var index = prefixedBinaryString.startIndex

    while index < prefixedBinaryString.endIndex {
        let endIndex = prefixedBinaryString.index(index, offsetBy: 8, limitedBy: prefixedBinaryString.endIndex) ?? prefixedBinaryString.endIndex
        let byteString = prefixedBinaryString[index ..< endIndex]

        if let byte = UInt8(byteString, radix: 2) {
            byteArray.append(byte)
        } else {
            break
        }

        index = endIndex
    }

    return Data(byteArray)
}
