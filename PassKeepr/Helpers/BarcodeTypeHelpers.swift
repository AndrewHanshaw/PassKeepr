//
//  BarcodeTypeHelpers.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 2/17/24.
//

import Foundation
import SwiftUI

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
        }
    }

    static func keyboardTypeForTextField(type: Binding<BarcodeType>) -> UIKeyboardType {
        switch type.wrappedValue {
            case BarcodeType.code128, BarcodeType.code39, BarcodeType.code93:
                return .default
            default:
                return .numberPad
        }
    }
}
