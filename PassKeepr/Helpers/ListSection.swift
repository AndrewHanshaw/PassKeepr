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
    
    var type: passType {
        list.first?.type ?? ListItem().type
    }
    
    var sectionHeaderTitle: String {
        "\(type)"
    }
    
    var body: some View {
        Section(header: sectionHeader(sectionHeaderTitle, isExpanded: $isListExpanded)) {
            if isListExpanded {
                ForEach(list) { ListItem in
                    NavigationLink(ListItem.name, destination: Text(ListItem.name))
                        .swipeActions(allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteItemByID(ListItem.id)
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
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
        previewList.filter { $0.type == passType.barcodePass }
    }
    
    return List {
        ListSection(list:filteredList)
    }
}
