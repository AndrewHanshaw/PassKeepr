//
//  ListStruct.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 11/8/23.
//

import Foundation

struct PassObject: Codable, Identifiable, Equatable, Hashable {
    var id: UUID
    var passName: String
    var passType: PassType
    var identificationString: String?
    var barcodeString: String?
    var barcodeType: BarcodeType?
    var qrCodeString: String?
    var qrCodeCorrectionLevel: QrCodeCorrectionLevel?
    var noteString: String?
    var name: String?
    var title: String?
    var businessName: String?
    var phoneNumber: String?
    var email: String?
    var pictureID: String? // placeholder until I figure out how to handle images
    var foregroundColor: UInt
    var backgroundColor: UInt
    var textColor: UInt
}

enum PassType: Int, Codable, Identifiable, CaseIterable {
    case identificationPass, barcodePass, qrCodePass, notePass, businessCardPass, picturePass
    var id: Self { self }
}

enum QrCodeCorrectionLevel: Codable, CustomStringConvertible, CaseIterable {
    case low
    case medium
    case quartile
    case high

    var description : String {
        switch self {
            case .low: return "L"
            case .medium: return "M"
            case .quartile: return "Q"
            case .high: return "H"
        }
    }
}

enum BarcodeType: Codable, CustomStringConvertible, CaseIterable {
    case code128
    case code93
    case code39
    case upce

    var description : String {
        switch self {
            case .code128: return "Code 128"
            case .code93: return "Code 93"
            case .code39: return "Code 39"
            case .upce: return "UPC-E"
        }
    }
}
