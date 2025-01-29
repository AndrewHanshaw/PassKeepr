import SwiftUI

struct EAN13View: View {
    @Binding var value: String
    var border: Double

    var barcodeDataBuffer: Data {
        stringToEAN13BarcodeData(value) ?? Data()
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
    EAN13View(value: .constant("5901234123457"), border: 20)
}

import Foundation

func stringToEAN13BarcodeData(_ stringValue: String) -> Data? {
    // Ensure the input is a 13-character string or pad with leading zeros
    let paddedString = stringValue.padding(toLength: 13, withPad: "0", startingAt: 0)

    // Define the 7-bit encoding patterns for EAN-13
    let digitTo7BitLeftEven: [Int: String] = [
        0: "0001101", // Even parity for left-hand side
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

    let digitTo7BitLeftOdd: [Int: String] = [
        0: "0100111", // Odd parity for left-hand side
        1: "0110011",
        2: "0011011",
        3: "0100001",
        4: "0011101",
        5: "0111001",
        6: "0000101",
        7: "0010001",
        8: "0001001",
        9: "0010111",
    ]

    let digitTo7BitRight: [Int: String] = [
        0: "1110010", // Right-hand side (fixed parity)
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

    // Determine the parity encoding for the left-hand side based on the first digit
    let firstDigit = Int(String(paddedString.first!))!
    let parityTable: [Int: [Int]] = [
        0: [0, 0, 0, 0, 0, 0],
        1: [0, 0, 1, 0, 1, 1],
        2: [0, 0, 1, 1, 0, 1],
        3: [0, 0, 1, 1, 1, 0],
        4: [0, 1, 0, 0, 1, 1],
        5: [0, 1, 1, 0, 0, 1],
        6: [0, 1, 1, 1, 0, 0],
        7: [0, 1, 0, 1, 0, 1],
        8: [0, 1, 0, 1, 1, 0],
        9: [0, 1, 1, 0, 1, 0],
    ]

    guard let paritySequence = parityTable[firstDigit] else {
        return nil
    }

    // Encode the left-hand side (digits 2-7) using the parity sequence
    let leftDigits = paddedString.dropFirst().prefix(6)
    let leftBinaryString = leftDigits.enumerated().compactMap { index, digit in
        guard let digitValue = Int(String(digit)) else { return nil }
        return (paritySequence[index] == 0) ? digitTo7BitLeftEven[digitValue] : digitTo7BitLeftOdd[digitValue]
    }.joined()

    // Encode the right-hand side (digits 8-13) using fixed parity
    let rightDigits = paddedString.suffix(6)
    let rightBinaryString = rightDigits.compactMap { digit in
        guard let digitValue = Int(String(digit)) else { return nil }
        return digitTo7BitRight[digitValue]
    }.joined()

    // Append start, middle, and end patterns
    let prefixedBinaryString = "101" + leftBinaryString + "01010" + rightBinaryString + "101" + "00000"

    // Convert the binary string to a byte array
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
