import SwiftUI

struct ITF14View: View {
    @Binding var value: String
    var border: Double

    var barcodeDataBuffer: Data {
        stringToITF14BarcodeData(value) ?? Data()
    }

    var numberOfSegments: Int {
        // Start (4) + 7 pairs * (5 bars + 5 spaces interleaved, avg ~2 modules each) + end (5)
        // Computed dynamically from the actual bit pattern length
        let bitCount = barcodeDataBuffer.count * 8
        return min(bitCount, 255)
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
    ITF14View(value: .constant("12345678901231"), border: 20)
}

import Foundation

func stringToITF14BarcodeData(_ stringValue: String) -> Data? {
    guard stringValue.count == 14, stringValue.allSatisfy({ $0.isNumber }) else {
        return nil
    }

    // Interleaved 2 of 5 digit patterns: 5 elements each, 1 = wide, 0 = narrow
    let digitPatterns: [Character: [Int]] = [
        "0": [0, 0, 1, 1, 0],
        "1": [1, 0, 0, 0, 1],
        "2": [0, 1, 0, 0, 1],
        "3": [1, 1, 0, 0, 0],
        "4": [0, 0, 1, 0, 1],
        "5": [1, 0, 1, 0, 0],
        "6": [0, 1, 1, 0, 0],
        "7": [0, 0, 0, 1, 1],
        "8": [1, 0, 0, 1, 0],
        "9": [0, 1, 0, 1, 0],
    ]

    // Narrow = 1 module, wide = 3 modules
    func bar(_ wide: Int) -> String {
        wide == 1 ? "111" : "1"
    }
    func space(_ wide: Int) -> String {
        wide == 1 ? "000" : "0"
    }

    var binaryString = "1010" // Start pattern: narrow bar, narrow space x2

    let digits = Array(stringValue)
    for pairStart in stride(from: 0, to: 14, by: 2) {
        guard let bars = digitPatterns[digits[pairStart]],
              let spaces = digitPatterns[digits[pairStart + 1]]
        else { return nil }

        // Interleave: bars from first digit, spaces from second digit
        for i in 0 ..< 5 {
            binaryString += bar(bars[i])
            binaryString += space(spaces[i])
        }
    }

    binaryString += "11101" // End pattern: wide bar, narrow space, narrow bar
    binaryString += "00000" // Trailing quiet zone

    var byteArray: [UInt8] = []
    var index = binaryString.startIndex

    while index < binaryString.endIndex {
        let endIndex = binaryString.index(index, offsetBy: 8, limitedBy: binaryString.endIndex) ?? binaryString.endIndex
        let byteString = binaryString[index ..< endIndex]

        if let byte = UInt8(byteString, radix: 2) {
            byteArray.append(byte)
        } else {
            break
        }

        index = endIndex
    }

    return Data(byteArray)
}
