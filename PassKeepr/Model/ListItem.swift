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
    var identificationString: String?
    var barcodeString: String?
    var qrCodeString: String?
    var noteString: String?
    var name: String?
    var title: String?
    var businessName: String?
    var phoneNumber: String?
    var email: String?
    var pictureID: String? // placeholder until I figure out how to handle images
}

enum PassType: Int, Codable, Identifiable {
    case identificationPass, barcodePass, qrCodePass, notePass, businessCardPass, picturePass
    var id: Self { self }
}
