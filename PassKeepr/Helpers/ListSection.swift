import SwiftUI

struct ListSection: View {
    @Environment(ModelData.self) var modelData

    @State private var isListExpanded = true

    @State var list: [PassObject]

    var type: PassType {
        list.first?.passType ?? PassType.barcodePass
    }

    var body: some View {
        Section(header: sectionHeader(type, isExpanded: $isListExpanded)) {
            if isListExpanded {
                ForEach($list) { $passObject in
                    NavigationLink(passObject.passName, destination: EditPass(passObject: $passObject))
                        .swipeActions(allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                modelData.deleteItemByID(passObject.id)
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
        Image(systemName: PassObjectHelpers.GetSystemIcon(type))
        Text(PassObjectHelpers.GetStringPlural(type))
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
    let previewList = ModelData(preview: true).preLoadedPassObjects

    var filteredList: [PassObject] {
        previewList.filter { $0.passType == PassType.barcodePass }
    }

    return List {
        ListSection(list: filteredList)
            .environment(ModelData())
    }
}
