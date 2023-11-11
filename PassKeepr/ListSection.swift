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
    
    var list: [ListItem] {
        modelData.listItems
    }
    
    var body: some View {
        Section(header: sectionHeader("Type 1 Passes", isExpanded: $isListExpanded)) {
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
    List {
        ListSection()
            .environment(ModelData())
    }
}
