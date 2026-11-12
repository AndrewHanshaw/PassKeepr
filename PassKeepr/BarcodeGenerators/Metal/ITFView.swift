import SwiftUI

struct ITFView: View {
    @Binding var value: String
    var border: Double

    var barcodeDataBuffer: Data {
        stringToITFBarcodeData(value) ?? Data()
    }

    // Start (4 modules) + 9 modules per digit (each pair is 18 modules: 6 narrow + 4 wide at 3 modules) + stop (5 modules)
    var numberOfSegments: Int {
        min(9 + 9 * value.count, 255)
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
    ITFView(value: .constant("12345678901231"), border: 20)
}

import Foundation

func stringToITFBarcodeData(_ stringValue: String) -> Data? {
    // Interleaved 2 of 5 requires an even number of digits. Max 26 so the module count (9 + 9n) fits in a UInt8.
    guard !stringValue.isEmpty,
          stringValue.count.isMultiple(of: 2),
          stringValue.count <= 26,
          stringValue.allSatisfy({ $0.isASCII && $0.isNumber })
    else {
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
    for pairStart in stride(from: 0, to: digits.count, by: 2) {
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

    // Pad on the right so the final partial byte stays left-aligned (MSB first)
    while binaryString.count % 8 != 0 {
        binaryString += "0"
    }

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
