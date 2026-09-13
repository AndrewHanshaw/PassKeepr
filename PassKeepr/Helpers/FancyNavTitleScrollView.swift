// Source - https://stackoverflow.com/a/79401545
// Posted by levous
// Retrieved 2026-07-16, License - CC BY-SA 4.0

import SwiftUI

struct FancyNavTitleScrollView<TitleView: View, NavBarView: View, Content: View>: View {
    @State private var showingScrolledTitle = false

    let navigationTitle: String
    let titleView: () -> TitleView
    let navBarView: () -> NavBarView
    var transitionOffest: CGFloat = 30
    let content: () -> Content

    var body: some View {
        GeometryReader { outer in
            ScrollView {
                VStack {
                    titleView()
                        .opacity(showingScrolledTitle ? 0 : 1)
                    content()
                }
                .background {
                    scrollDetector(topInsets: outer.safeAreaInsets.top)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                navBarView()
                    .opacity(showingScrolledTitle ? 1 : 0.0001)
                    .animation(.easeInOut, value: showingScrolledTitle)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func scrollDetector(topInsets: CGFloat) -> some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .global).minY
            let isUnderToolbar = minY - topInsets < -transitionOffest
            Color.clear
                .onChange(of: isUnderToolbar) { _, newVal in
                    showingScrolledTitle = newVal
                }
        }
    }
}
