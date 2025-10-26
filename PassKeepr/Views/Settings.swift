import SwiftUI

struct Settings: View {
    @EnvironmentObject var modelData: ModelData

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var isDocumentPickerPresented: Bool = false
    @Binding var isInfoPagePresented: Bool

    var body: some View {
        Button("Delete All Passes", systemImage: "trash", role: .destructive) {
            modelData.deleteAllItems()
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 2.0)
                .onEnded { _ in
                    modelData.deleteAllItems()
                    modelData.deleteDataFile()
                    presentationMode.wrappedValue.dismiss()
                }
        )

        Button("About PassKeepr", systemImage: "info.circle") {
            isInfoPagePresented.toggle()
        }
    }
}

#Preview {
    Settings(isInfoPagePresented: .constant(false))
        .environment(MockModelData())
}
