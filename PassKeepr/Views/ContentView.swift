import SwiftUI

struct ContentView: View {
    @Binding var importedPassURL: URL?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass == .regular {
            // iPad: two-column split view
            NavigationSplitView {
                PassGridView(importedPassURL: $importedPassURL)
                    .navigationSplitViewColumnWidth(min: 280, ideal: 320)
            } detail: {
                LandscapeDetailPane()
                    .navigationSplitViewColumnWidth(min: 320, ideal: 400)
            }
        } else {
            // iPhone: NavigationStack required for zoom transition support
            NavigationStack {
                PassGridView(importedPassURL: $importedPassURL)
            }
        }
    }
}

#Preview {
    ContentView(importedPassURL: .constant(nil))
        .environmentObject(ModelData())
        .environmentObject(pkPassSigner())
}
