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

// Fix for an iOS 18 bug. Otherwise if you drag with your finger on a button it will click that button. (see https://www.reddit.com/r/SwiftUI/comments/1hf4wwq/sheet_button_triggering_while_scrolling/)
struct HighProrityDragGestureModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
        } else {
            content
                .highPriorityGesture(DragGesture())
        }
    }
}

extension View {
    func highProrityDragGestureModifier() -> some View {
        modifier(HighProrityDragGestureModifier())
    }
}

struct PopoverModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .padding(10)
        } else {
            content
                .padding(5)
        }
    }
}

extension View {
    func popoverModifier() -> some View {
        modifier(PopoverModifier())
    }
}
