//
//  BarcodeTypeHelpers.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 2/17/24.
//

import Foundation

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
}
