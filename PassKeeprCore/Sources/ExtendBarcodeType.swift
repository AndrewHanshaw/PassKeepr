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
        case BarcodeType.code39Checksum:
            return "Code 39 Checksum barcodes may contain 0-9, A-Z, spaces, and the following special characters: - . $ / + %, with a Mod 43 checksum digit"
        case BarcodeType.code39FullASCII:
            return "Code 39 Full ASCII barcodes may contain any standard ASCII character"
        case BarcodeType.code39FullASCIIChecksum:
            return "Code 39 Full ASCII Checksum barcodes may contain any standard ASCII character, with a Mod 43 checksum digit"
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
        case BarcodeType.itf14:
            return "ITF-14 barcodes must contain exactly 14 digits"
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
        case BarcodeType.code39, BarcodeType.code93, BarcodeType.code39Checksum:
            let regex = /^[0-9a-zA-Z \-$%.\/+]+$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.code39FullASCII, BarcodeType.code39FullASCIIChecksum:
            let regex = /^[ -~]+$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.upce:
            let regex = /^\d{6}$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.upca:
            let regex = /^\d{12}$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.ean13:
            let regex = /^\d{13}$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.ean8:
            let regex = /^\d{8}$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.itf14:
            let regex = /^\d{14}$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.pdf417:
            let regex = /^[ -~]+$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.qr:
            let regex = /^.+$/
            return string.firstMatch(of: regex) != nil
        }
    }

    #if canImport(UIKit)
        func keyboardType() -> UIKeyboardType {
            switch self {
            case BarcodeType.code128, BarcodeType.code39, BarcodeType.code93, BarcodeType.code39Checksum, BarcodeType.code39FullASCII, BarcodeType.code39FullASCIIChecksum:
                return .default
            default:
                return .numberPad
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
        case .code39Checksum: return BarcodeCategory.oneDimensional
        case .code39FullASCII: return BarcodeCategory.oneDimensional
        case .code39FullASCIIChecksum: return BarcodeCategory.oneDimensional
        case .upce: return BarcodeCategory.oneDimensional
        case .upca: return BarcodeCategory.oneDimensional
        case .ean13: return BarcodeCategory.oneDimensional
        case .ean8: return BarcodeCategory.oneDimensional
        case .itf14: return BarcodeCategory.oneDimensional
        case .pdf417: return BarcodeCategory.oneDimensional
        case .qr: return BarcodeCategory.twoDimensional
        }
    }
}
