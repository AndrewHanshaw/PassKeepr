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
}
