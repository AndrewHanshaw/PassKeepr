import SwiftUI

struct TextFieldLabelModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 27.0, *) {
            content
                .monospaced()
        } else {
            content
        }
    }
}

extension View {
    func textFieldLabelModifier() -> some View {
        modifier(TextFieldLabelModifier())
    }
}
