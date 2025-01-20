import SwiftUI

private struct ViewWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = CGSizeZero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct ViewSizeReader: ViewModifier {
    @Binding var size: CGSize

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ViewWidthPreferenceKey.self, value: geometry.size)
            }
        )
        .onPreferenceChange(ViewWidthPreferenceKey.self) { size in
            self.size = size
        }
    }
}

extension View {
    func readSize(into size: Binding<CGSize>) -> some View {
        modifier(ViewSizeReader(size: size))
    }
}
