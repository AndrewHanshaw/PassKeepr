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
    var type: Int
    
    init() {
        self.id = 1000
        self.type = 0 // Set default type value
        self.name = "Default Name" // Set default name value
    }
}
