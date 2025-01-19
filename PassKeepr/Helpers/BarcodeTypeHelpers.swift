import Foundation
import SwiftUI
import Vision

class BarcodeTypeHelpers {
    static func GetBarcodeTypeDescription(_ type: BarcodeType) -> String {
        switch type {
        case BarcodeType.code128:
            return "Code 128 barcodes may contain any standard ASCII character"
        case BarcodeType.code93:
            return "Code 93 barcodes may contain 0-9, A-Z, - . $ / + %"
        default:
            return "default text"
        }
    }

    static func GetIsEnteredBarcodeValueValid(string: String, type: BarcodeType) -> Bool {
        switch type {
        case BarcodeType.code128:
            let regex = /^[ -~]+$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.code39, BarcodeType.code93:
            let regex = /^[0-9a-zA-Z \-$%.\/+]+$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.upce:
            let regex = /^\d{6}$/
            return string.firstMatch(of: regex) != nil
        case BarcodeType.pdf417:
            return true
        }
    }

    static func keyboardTypeForTextField(type: BarcodeType) -> UIKeyboardType {
        switch type {
        case BarcodeType.code128, BarcodeType.code39, BarcodeType.code93:
            return .default
        default:
            return .numberPad
        }
    }
}

extension VNBarcodeSymbology {
    func toBarcodeType() -> BarcodeType? {
        switch self {
        case VNBarcodeSymbology.code128:
            return BarcodeType.code128
        case VNBarcodeSymbology.code39:
            return BarcodeType.code39
        case VNBarcodeSymbology.code93:
            return BarcodeType.code93
        case VNBarcodeSymbology.upce:
            return BarcodeType.upce
        default:
            return nil
        }
    }
}
