import SwiftUI

struct SoftTopBottomScrollEdgeEffectModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.scrollEdgeEffectStyle(.soft, for: [.top, .bottom])
        } else {
            content
        }
    }
}

extension View {
    func softTopBottomScrollEdgeEffectStyleIfAvailable() -> some View {
        modifier(SoftTopBottomScrollEdgeEffectModifier())
    }
}
