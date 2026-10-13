import SwiftUI

struct ContentView: View {
    @Binding var importedPassURL: URL?
    @EnvironmentObject var modelData: ModelData
    @State private var addButtonCenter: CGPoint?

    var body: some View {
        ZStack {
            NavigationSplitView {
                PassGridView(importedPassURL: $importedPassURL, addButtonCenter: $addButtonCenter)
                    .navigationSplitViewColumnWidth(min: passGridMinWidth(forColumns: 2), ideal: passGridMinWidth(forColumns: 2) + 20)
            } detail: {
                LandscapeDetailPane()
                    .navigationSplitViewColumnWidth(min: 320, ideal: 400)
            }

            // Empty state overlay at window level (no parent coordinate conversions)
            if modelData.passObjects.isEmpty {
                NoPassesToShow(addButtonCenter: addButtonCenter)
            }
        }
    }
}

#Preview {
    ContentView(importedPassURL: .constant(nil))
        .environmentObject(ModelData())
        .environmentObject(pkPassSigner())
}
