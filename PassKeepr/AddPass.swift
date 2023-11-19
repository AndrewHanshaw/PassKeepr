//
//  AddPass.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 11/12/23.
//

import SwiftUI

struct AddPass: View {
    @Environment(ModelData.self) var modelData
    var addedPass = ListItem(id: 1, name: "added pass", type: 2)
        
    var body: some View {
        VStack {
            Spacer()
            
            Button ("Add Pass") {
                modelData.listItems.append(addedPass)
                encode("data.json", modelData.listItems)
            }
            
            Spacer()
        }
    }
}
    
#Preview {
    AddPass()
        .environment(ModelData())
}


