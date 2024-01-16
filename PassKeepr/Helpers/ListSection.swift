//
//  ListSection.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 11/8/23.
//

import SwiftUI

struct ListSection: View {
    @Environment(ModelData.self) var modelData

    @State private var isListExpanded = true

    @State var list: [ListItem]

    var type: PassType {
        list.first?.passType ?? PassType.barcodePass
    }

    var body: some View {
        Section(header: sectionHeader(type, isExpanded: $isListExpanded)) {
            if isListExpanded {
                ForEach($list) { $ListItem in
                    NavigationLink(ListItem.passName, destination: EditPass(listItem: $ListItem))
                        .swipeActions(allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                modelData.deleteItemByID(ListItem.id)
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                }
            }
        }
    }
}

private func sectionHeader(_ type: PassType, isExpanded: Binding<Bool>) -> some View {
    HStack {
        Text(ListItemHelpers.GetStringPlural(type))
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
    let previewList = ModelData(preview: true).listItems

    var filteredList: [ListItem] {
        previewList.filter { $0.passType == PassType.barcodePass }
    }

    return List {
        ListSection(list:filteredList)
    }
}
