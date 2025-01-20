import SwiftUI

struct Code39View: View {
    @Binding var value: String
    var border: Double

    var numberOfSegments: Int {
        min((value.count * 13) + 27, 255)
    }

    var barcodeDataBuffer: Data {
        stringToCode39BarcodeData(value.uppercased()) ?? Data()
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
    Code39View(value: .constant("WIKIPEDIA"), border: 20)
}

import Foundation

func stringToCode39BarcodeData(_ stringValue: String) -> Data? {
    let characterTo13Bit: [Character: String] = [
        "A": "1101010010110",
        "B": "1011010010110",
        "C": "1101101001010",
        "D": "1010110010110",
        "E": "1101011001010",
        "F": "1011011001010",
        "G": "1010100110110",
        "H": "1101010011010",
        "I": "1011010011010",
        "J": "1010110011010",
        "K": "1101010100110",
        "L": "1011010100110",
        "M": "1101101010010",
        "N": "1010110100110",
        "O": "1101011010010",
        "P": "1011011010010",
        "Q": "1010101100110",
        "R": "1101010110010",
        "S": "1011010110010",
        "T": "1010110110010",
        "U": "1100101010110",
        "V": "1001101010110",
        "W": "1100110101010",
        "X": "1001011010110",
        "Y": "1100101101010",
        "Z": "1001101101010",
        "0": "1010011011010",
        "1": "1101001010110",
        "2": "1011001010110",
        "3": "1101100101010",
        "4": "1010011010110",
        "5": "1101001101010",
        "6": "1011001101010",
        "7": "1010010110110",
        "8": "1101001011010",
        "9": "1011001011010",
        " ": "1001101011010",
        "-": "1001010110110",
        "$": "1001001001010",
        "%": "1010010010010",
        ".": "1100101011010",
        "/": "1001001010010",
        "+": "1001010010010",
    ]

    var binaryString = stringValue.enumerated().compactMap { _, character in
        guard
            let encodedCharacter = characterTo13Bit[character]
        else {
            return nil
        }
        return encodedCharacter
    }.joined()

    binaryString = "1001011011010" + binaryString + "100101101101" + "00000000"

    var byteArray: [UInt8] = []
    var index = binaryString.startIndex

    while index < binaryString.endIndex {
        let endIndex = binaryString.index(index, offsetBy: 8, limitedBy: binaryString.endIndex) ?? binaryString.endIndex
        let byteString = binaryString[index ..< endIndex]

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
