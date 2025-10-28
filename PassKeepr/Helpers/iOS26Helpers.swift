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

struct GlassProminentButtonStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.buttonStyle(GlassProminentButtonStyle())
        } else {
            content
        }
    }
}

extension View {
    func glassProminentButtonStyleIfAvailable() -> some View {
        modifier(GlassProminentButtonStyleModifier())
    }
}

struct TextFieldPopoverModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .padding([.top, .bottom], 16)
                .padding([.leading, .trailing], 24)
        } else {
            content
                .padding(8)
        }
    }
}

extension View {
    func textFieldPopoverModifier() -> some View {
        modifier(TextFieldPopoverModifier())
    }
}

struct ListSectionTextEditorModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    var placeholderText: String

    var isEnteredTextEmpty: Bool

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
//                .scrollDisabled(true) // This prevents all newline scrolling on iOS 26. I'd rather just have the clipping
                .overlay(alignment: .leading) {
                    if isEnteredTextEmpty {
                        Text(placeholderText)
                            .foregroundColor(.gray.opacity(0.7))
                            .padding(.horizontal, 5)
                            .allowsHitTesting(false)
                    }
                }
                .padding(14)
                .listSectionBackgroundModifier()
        } else {
            content
                .scrollDisabled(true) // Otherwise adding new lines will momentarily clip on the vertical edge as it scrolls
                .overlay(alignment: .topLeading) {
                    if isEnteredTextEmpty {
                        Text(placeholderText)
                            .foregroundColor(.gray.opacity(0.7))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 8)
                            .allowsHitTesting(false)
                    }
                }
                .padding(14)
                .listSectionBackgroundModifier()
        }
    }
}

extension View {
    func listSectionTextEditorModifier(placeholderText: String,
                                       isEnteredTextEmpty: Bool) -> some View
    {
        modifier(ListSectionTextEditorModifier(placeholderText: placeholderText, isEnteredTextEmpty: isEnteredTextEmpty))
    }
}

struct AccentColorProminentButtonStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.tint(.accentColor).interactive())
        } else {
            content
                .background(Color.accentColor)
                .clipShape(.rect(cornerRadius: 12))
        }
    }
}

extension View {
    func accentColorProminentButtonStyleIfAvailable() -> some View {
        modifier(AccentColorProminentButtonStyleModifier())
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
