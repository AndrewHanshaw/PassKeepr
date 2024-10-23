import SwiftUI

struct Code93View: View {
    @Binding var value: String

    var numberOfSegments: Int {
        (value.count * 9) + 1 + 18 + 18
    }

    var barcodeDataBuffer: Data {
        stringToCode93BarcodeData(value.uppercased()) ?? Data()
    }

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .colorEffect(ShaderLibrary.OneDimensionalBarcodeFilter(.float(geometry.size.width), .data(barcodeDataBuffer), .data(Data([UInt8(numberOfSegments)]))))
        }
    }
}

#Preview {
    Code93View(value: .constant("TEST93"))
}

import Foundation

func stringToCode93BarcodeData(_ stringValue: String) -> Data? {
    var tempString = stringValue

    let characterTo9Bit: [Character: [String: Int]] = [
        "0": ["100010100": 0],
        "1": ["101001000": 1],
        "2": ["101000100": 2],
        "3": ["101000010": 3],
        "4": ["100101000": 4],
        "5": ["100100100": 5],
        "6": ["100100010": 6],
        "7": ["101010000": 7],
        "8": ["100010010": 8],
        "9": ["100001010": 9],
        "A": ["110101000": 10],
        "B": ["110100100": 11],
        "C": ["110100010": 12],
        "D": ["110010100": 13],
        "E": ["110010010": 14],
        "F": ["110001010": 15],
        "G": ["101101000": 16],
        "H": ["101100100": 17],
        "I": ["101100010": 18],
        "J": ["100110100": 19],
        "K": ["100011010": 20],
        "L": ["101011000": 21],
        "M": ["101001100": 22],
        "N": ["101000110": 23],
        "O": ["100101100": 24],
        "P": ["100010110": 25],
        "Q": ["110110100": 26],
        "R": ["110110010": 27],
        "S": ["110101100": 28],
        "T": ["110100110": 29],
        "U": ["110010110": 30],
        "V": ["110011010": 31],
        "W": ["101101100": 32],
        "X": ["101100110": 33],
        "Y": ["100110110": 34],
        "Z": ["100111010": 35],
        "-": ["100101110": 36],
        ".": ["111010100": 37],
        " ": ["111010010": 38],
        "$": ["111001010": 39],
        "/": ["101101110": 40],
        "+": ["101110110": 41],
        "%": ["110101110": 42],
        "(": ["100100110": 43], // ($)
        ")": ["111011010": 44], // (%)
        "{": ["111010110": 45], // (/)
        "}": ["100110010": 46], // (+)
        "~": ["101011110": 47], // start/stop
    ]

    var weightedSum = 0

    // Determine the weighted sum of the given string
    for (index, character) in tempString.enumerated() {
        // kvp is a pair [String : Int] that holds the encoded char
        // and the weight associated with the character
        let kvp = characterTo9Bit[character]!
        for (_, weightedValue) in kvp {
            // generate the weighted sum for this character per the code93 algo
            var currentPos: Int = (tempString.count - index) % 20
            if currentPos == 0 {
                currentPos = 20
            }
            weightedSum += currentPos * weightedValue
        }
    }

    let checkCharC = (weightedSum % 47)

    // Get the character associated with checkCharC, append it to the string
    for (character, nestedDictionary) in characterTo9Bit {
        for (_, integerValue) in nestedDictionary {
            if integerValue == checkCharC {
                tempString += String(character)
                break
            }
        }
    }

    var weightedSum2 = 0

    // Generate the new weighted sum given the original string + check value C
    for (index, character) in tempString.enumerated() {
        // kvp is a pair [String : Int] that holds the encoded char
        // and the weight associated with the character
        let kvp = characterTo9Bit[character]!
        for (_, weightedValue) in kvp {
            // generate the weighted sum for this character per the code93 algo
            weightedSum2 += (tempString.count - index) * weightedValue
        }
    }

    let checkCharK = (weightedSum2 % 47)

    // Get the character associated with checkCharK, append it to the string
    for (character, nestedDictionary) in characterTo9Bit {
        for (_, integerValue) in nestedDictionary {
            if integerValue == checkCharK {
                tempString += String(character)
                break
            }
        }
    }

    var encodedString = ""

    // Encode the string incl. check C and K into binary format
    for (_, character) in tempString.enumerated() {
        // kvp is a pair [String : Int] that holds the encoded char
        // and the weight associated with the character
        let kvp = characterTo9Bit[character]!
        for (encodedValue, _) in kvp {
            // capture the encoded representation of the character
            // and append it to the output string
            encodedString += encodedValue
        }
    }

    // append start/stop characters, end bar, and trailing zeros so
    // encodedString fits exactly within the byte array (otherwise the byte that
    // isn't full is shifted to the right)
    encodedString = "101011110" + encodedString + "101011110" + "1" + "00000000"

    var byteArray: [UInt8] = []
    var index = encodedString.startIndex

    while index < encodedString.endIndex {
        let endIndex = encodedString.index(index, offsetBy: 8, limitedBy: encodedString.endIndex) ?? encodedString.endIndex
        let byteString = encodedString[index ..< endIndex]

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
