import Foundation
import SwiftUI
import Vision

extension BarcodeType {
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
        case BarcodeType.pdf417:
            return "PDF-417 barcodes may contain any standard ASCII character"
        case BarcodeType.ean13:
            return "EAN-13 barcodes must contain exactly 13 digits"
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
            let regex = /^\d{6}$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.ean13:
            let regex = /^\d{13}$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.pdf417:
            let regex = /^[ -~]+$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.qr:
            let regex = /^.+$/
            return string.firstMatch(of: regex) != nil
        }
    }

    func keyboardType() -> UIKeyboardType {
        switch self {
        case BarcodeType.code128, BarcodeType.code39, BarcodeType.code93:
            return .default
        default:
            return .numberPad
        }
    }

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
        case .ean13: return BarcodeCategory.oneDimensional
        case .pdf417: return BarcodeCategory.oneDimensional
        case .qr: return BarcodeCategory.twoDimensional
        }
    }
}
