import Foundation

/// Mod 43 checksum values for Code 39 characters
private let code39ChecksumValues: [Character: Int] = [
    "0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9,
    "A": 10, "B": 11, "C": 12, "D": 13, "E": 14, "F": 15, "G": 16, "H": 17, "I": 18,
    "J": 19, "K": 20, "L": 21, "M": 22, "N": 23, "O": 24, "P": 25, "Q": 26, "R": 27,
    "S": 28, "T": 29, "U": 30, "V": 31, "W": 32, "X": 33, "Y": 34, "Z": 35,
    "-": 36, ".": 37, " ": 38, "$": 39, "/": 40, "+": 41, "%": 42,
]

private let checksumValueToChar: [Int: Character] = Dictionary(
    uniqueKeysWithValues: code39ChecksumValues.map { ($1, $0) }
)

/// Computes the Mod 43 checksum character for a Code 39 string.
func code39ChecksumChar(for string: String) -> Character? {
    var sum = 0
    for char in string.uppercased() {
        guard let value = code39ChecksumValues[char] else { return nil }
        sum += value
    }
    return checksumValueToChar[sum % 43]
}

/// Full ASCII encoding table: maps each ASCII character to its Code 39 sequence
private let fullASCIITable: [Character: String] = [
    "\0": "%U", "\u{01}": "$A", "\u{02}": "$B", "\u{03}": "$C",
    "\u{04}": "$D", "\u{05}": "$E", "\u{06}": "$F", "\u{07}": "$G",
    "\u{08}": "$H", "\u{09}": "$I", "\u{0A}": "$J", "\u{0B}": "$K",
    "\u{0C}": "$L", "\u{0D}": "$M", "\u{0E}": "$N", "\u{0F}": "$O",
    "\u{10}": "$P", "\u{11}": "$Q", "\u{12}": "$R", "\u{13}": "$S",
    "\u{14}": "$T", "\u{15}": "$U", "\u{16}": "$V", "\u{17}": "$W",
    "\u{18}": "$X", "\u{19}": "$Y", "\u{1A}": "$Z", "\u{1B}": "%A",
    "\u{1C}": "%B", "\u{1D}": "%C", "\u{1E}": "%D", "\u{1F}": "%E",
    " ": " ", "!": "/A", "\"": "/B", "#": "/C", "$": "/D", "%": "/E",
    "&": "/F", "'": "/G", "(": "/H", ")": "/I", "*": "/J", "+": "/K",
    ",": "/L", "-": "-", ".": ".", "/": "/O",
    "0": "0", "1": "1", "2": "2", "3": "3", "4": "4",
    "5": "5", "6": "6", "7": "7", "8": "8", "9": "9",
    ":": "/Z", ";": "%F", "<": "%G", "=": "%H", ">": "%I", "?": "%J",
    "@": "%V",
    "A": "A", "B": "B", "C": "C", "D": "D", "E": "E", "F": "F",
    "G": "G", "H": "H", "I": "I", "J": "J", "K": "K", "L": "L",
    "M": "M", "N": "N", "O": "O", "P": "P", "Q": "Q", "R": "R",
    "S": "S", "T": "T", "U": "U", "V": "V", "W": "W", "X": "X",
    "Y": "Y", "Z": "Z",
    "[": "%K", "\\": "%L", "]": "%M", "^": "%N", "_": "%O",
    "`": "%W",
    "a": "+A", "b": "+B", "c": "+C", "d": "+D", "e": "+E", "f": "+F",
    "g": "+G", "h": "+H", "i": "+I", "j": "+J", "k": "+K", "l": "+L",
    "m": "+M", "n": "+N", "o": "+O", "p": "+P", "q": "+Q", "r": "+R",
    "s": "+S", "t": "+T", "u": "+U", "v": "+V", "w": "+W", "x": "+X",
    "y": "+Y", "z": "+Z",
    "{": "%P", "|": "%Q", "}": "%R", "~": "%S", "\u{7F}": "%T",
]

/// Encodes a string using Code 39 Extended (Full ASCII) shift sequences.
func encodeFullASCII(_ string: String) -> String? {
    var result = ""
    for char in string {
        guard let encoded = fullASCIITable[char] else { return nil }
        result += encoded
    }
    return result
}
