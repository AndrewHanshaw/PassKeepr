//
//  ListStruct.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 11/8/23.
//

import Foundation

struct ListItem: Codable, Hashable, Identifiable {
    var id: Int
    var name: String
    var type: passType
}

extension ListItem {
    init() {
        self.id = 1000
        self.name = "Default Name" // Set default name value
        self.type = passType.identificationPass // Set default type value
    }
}

enum passType: Int, Codable, Identifiable {
    case identificationPass, barcodePass, qrCodePass, notePass, businessCardPass, picturePass
    var id: Self { self }
}
