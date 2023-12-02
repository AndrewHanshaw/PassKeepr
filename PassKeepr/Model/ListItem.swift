//
//  ListStruct.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 11/8/23.
//

import Foundation

struct ListItem: Codable, Identifiable, Equatable {
    var id: UUID
    var passName: String
    var passType: PassType
    var identificationNumber: Int?
    var barcodeNumber: Int?
    var qrCodeString: String?
    var noteString: String?
    var name: String?
    var title: String?
    var businessName: String?
    var phoneNumber: Int?
    var email: String?
}

enum PassType: Int, Codable, Identifiable {
    case identificationPass, barcodePass, qrCodePass, notePass, businessCardPass, picturePass
    var id: Self { self }
}
