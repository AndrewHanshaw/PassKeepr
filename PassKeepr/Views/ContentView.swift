import SwiftUI

struct ContentView: View {
    @Binding var importedPassURL: URL?

    // Deciding this by device idiom (rather than horizontalSizeClass) matters: on iPad,
    // resizing the app window (Split View / Stage Manager) can flip horizontalSizeClass to
    // .compact. If that were used here, it would tear down this whole NavigationSplitView
    // (discarding any pushed EditPass, and resetting PassGridView's measured gridWidth/scroll
    // state) and rebuild a totally different NavigationStack hierarchy in its place - causing
    // a visible flash of incorrect/clipped layout while things settle. NavigationSplitView
    // already collapses to a single column gracefully on its own when space is constrained,
    // preserving navigation and layout state across the resize.
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    @EnvironmentObject var modelData: ModelData
    @State private var addButtonCenter: CGPoint?

    var body: some View {
        if isPad {
            // iPad: two-column split view
            NavigationSplitView {
                PassGridView(importedPassURL: $importedPassURL, addButtonCenter: $addButtonCenter)
                    .navigationSplitViewColumnWidth(min: passGridMinWidth(forColumns: 2), ideal: passGridMinWidth(forColumns: 2) + 20)
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

            // Empty state overlay at window level (no parent coordinate conversions)
            if modelData.passObjects.isEmpty {
                NoPassesToShow(addButtonCenter: addButtonCenter)
            }
    }
}

#Preview {
    ContentView(importedPassURL: .constant(nil))
        .environmentObject(ModelData())
        .environmentObject(pkPassSigner())
}
