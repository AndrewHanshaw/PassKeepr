import Foundation
import SwiftUI
import Vision

public extension BarcodeType {
    func info() -> String {
        switch self {
        case BarcodeType.code128:
            return "Code 128 barcodes may contain any standard ASCII character"
        case BarcodeType.code93:
            return "Code 93 barcodes may contain 0-9, A-Z, spaces, and the following special characters: - . $ / + %"
        case BarcodeType.code39:
            return "Code 39 barcodes may contain 0-9, A-Z, spaces, and the following special characters: - . $ / + %"
        case BarcodeType.upce:
            return "UPC-E barcodes must contain exactly 6 digits"
        case BarcodeType.upca:
            return "UPC-A barcodes must contain exactly 12 digits"
        case BarcodeType.pdf417:
            return "PDF-417 barcodes may contain any standard ASCII character"
        case BarcodeType.ean13:
            return "EAN-13 barcodes must contain exactly 13 digits"
        case BarcodeType.ean8:
            return "EAN-8 barcodes must contain exactly 8 digits"
        case BarcodeType.itf:
            return "ITF (Interleaved 2 of 5, including ITF-14) barcodes must contain an even number of digits, from 2 to 26"
        case BarcodeType.qr, BarcodeType.none:
            return "default text"
        }
    }

    func isEnteredBarcodeValueValid(string: String) -> Bool {
        switch self {
        case BarcodeType.none:
            return false
        case BarcodeType.code128:
            let regex = /^[ -~]+$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.code39, BarcodeType.code93:
            let regex = /^[0-9a-zA-Z \-$%.\/+]+$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.upce:
            let regex = /^[0-9]{6}$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.upca:
            let regex = /^[0-9]{12}$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.ean13:
            let regex = /^[0-9]{13}$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.ean8:
            let regex = /^[0-9]{8}$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.itf:
            let regex = /^([0-9]{2}){1,13}$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.pdf417:
            let regex = /^[ -~]+$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.qr:
            let regex = /^.+$/
            return string.firstMatch(of: regex) != nil
        }
    }

    // True for every symbology that can only encode ASCII. QR (and `none`) accept arbitrary text.
    var acceptsOnlyASCII: Bool {
        switch self {
        case BarcodeType.qr, BarcodeType.none:
            return false
        default:
            return true
        }
    }

    #if canImport(UIKit)
        func keyboardType() -> UIKeyboardType {
            switch self {
            case BarcodeType.qr, BarcodeType.none:
                // Any text is allowed
                return .default
            case BarcodeType.code128, BarcodeType.code39, BarcodeType.code93, BarcodeType.pdf417:
                return .asciiCapable
            case BarcodeType.upce, BarcodeType.upca, BarcodeType.ean13, BarcodeType.ean8, BarcodeType.itf:
                // Not .numberPad: in some locales that shows non-ASCII numerals (e.g. Arabic-Indic), which can't be encoded.
                return .asciiCapableNumberPad
            }
        }
    #endif

    func doesBarcodeUseStripImage() -> Bool {
        switch self {
        case BarcodeType.code128, BarcodeType.qr, BarcodeType.pdf417, BarcodeType.none:
            return false
        default:
            return true
        }
    }

    func toBarcodeCategory() -> BarcodeCategory {
        switch self {
        case .none: return BarcodeCategory.none
        case .code128: return BarcodeCategory.oneDimensional
        case .code93: return BarcodeCategory.oneDimensional
        case .code39: return BarcodeCategory.oneDimensional
        case .upce: return BarcodeCategory.oneDimensional
        case .upca: return BarcodeCategory.oneDimensional
        case .ean13: return BarcodeCategory.oneDimensional
        case .ean8: return BarcodeCategory.oneDimensional
        case .itf: return BarcodeCategory.oneDimensional
        case .pdf417: return BarcodeCategory.oneDimensional
        case .qr: return BarcodeCategory.twoDimensional
        }
    }
}

public extension String {
    /// Replaces decimal digits from other scripts (Arabic-Indic, fullwidth, ...) with ASCII 0-9.
    /// Every other character is left unchanged.
    func normalizingDigitsToASCII() -> String {
        var scalars = String.UnicodeScalarView()
        for scalar in unicodeScalars {
            if !scalar.isASCII,
               scalar.properties.generalCategory == .decimalNumber,
               let value = scalar.properties.numericValue,
               (0 ... 9).contains(value)
            {
                scalars.append(Unicode.Scalar(UInt8(48 + Int(value))))
            } else {
                scalars.append(scalar)
            }
        }
        return String(scalars)
    }
}
