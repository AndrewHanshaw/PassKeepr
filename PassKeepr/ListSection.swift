//
//  ListSection.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 11/8/23.
//

import SwiftUI

struct ListSection: View {
    @State private var isListExpanded = true
    
    let list: [ListItem]
    
    var type: Int {
        list.first?.type ?? ListItem().type
    }
    
    var sectionHeaderTitle: String {
        "Type \(type) Passes"
    }
    
    var body: some View {
        Section(header: sectionHeader(sectionHeaderTitle, isExpanded: $isListExpanded)) {
            if isListExpanded {
                ForEach(list) { ListItem in
                    NavigationLink(ListItem.name, destination: Text(ListItem.name))
                }
            }
        }
    }
}

private func sectionHeader(_ title: String, isExpanded: Binding<Bool>) -> some View {
    HStack {
        Text(title)
        Spacer()
        Button {
            withAnimation {
                isExpanded.wrappedValue.toggle()
            }
        } label: {
            Label("Show", systemImage: "chevron.right.circle")
                .labelStyle(.iconOnly)
                .rotationEffect(.degrees(isExpanded.wrappedValue ? 90 : 0))
        }
    }
}

#Preview {
    let previewList = ModelData().listItems
    
    var filteredList: [ListItem] {
        previewList.filter { $0.type == 1 }
    }
    
    return List {
        ListSection(list:filteredList)
    }
}
