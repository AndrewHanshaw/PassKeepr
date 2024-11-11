import SwiftUI

private struct ViewWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ViewWidthReader: ViewModifier {
    @Binding var width: CGFloat

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ViewWidthPreferenceKey.self, value: geometry.size.width)
            }
        )
        .onPreferenceChange(ViewWidthPreferenceKey.self) { width in
            self.width = width
        }
    }
}

extension View {
    func readWidth(into width: Binding<CGFloat>) -> some View {
        modifier(ViewWidthReader(width: width))
    }
}
