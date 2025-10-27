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

struct ListSectionBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .background(colorScheme == .light ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 32))
        } else {
            content
                .background(colorScheme == .light ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 12))
        }
    }
}

extension View {
    func listSectionBackgroundModifier() -> some View {
        modifier(ListSectionBackgroundModifier())
    }
}

struct ToolbarConfirmButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .buttonStyle(GlassProminentButtonStyle())
        } else {
            content
                .labelStyle(.titleOnly)
        }
    }
}

extension View {
    func toolbarConfirmButtonModifier() -> some View {
        modifier(ToolbarConfirmButtonModifier())
    }
}

struct ToolbarCancelButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
        } else {
            content
                .labelStyle(.titleOnly)
        }
    }
}

extension View {
    func toolbarCancelButtonModifier() -> some View {
        modifier(ToolbarCancelButtonModifier())
    }
}
