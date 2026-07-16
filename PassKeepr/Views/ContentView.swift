import SwiftUI

struct ContentView: View {
    @Binding var importedPassURL: URL?

    var body: some View {
        NavigationView {
            PassGridView(importedPassURL: $importedPassURL, columnCount: 2)
        }
    }
}

#Preview {
    ContentView(importedPassURL: .constant(nil))
        .environmentObject(ModelData())
        .environmentObject(pkPassSigner())
}
