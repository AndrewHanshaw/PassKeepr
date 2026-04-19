import SwiftUI
import SwiftyCrop

extension SwiftyCropConfiguration.Colors {
    static func appColors(colorScheme: ColorScheme) -> SwiftyCropConfiguration.Colors {
        if #available(iOS 26, *) {
            return SwiftyCropConfiguration.Colors(
                cancelButton: Color.primary,
                interactionInstructions: Color.primary,
                saveButtonBackground: Color.accentColor,
                background: colorScheme == .light
                    ? Color(UIColor.secondarySystemBackground)
                    : Color(UIColor.systemBackground),
                cropHandle: Color.primary
            )
        } else {
            return SwiftyCropConfiguration.Colors(
                cancelButton: Color.primary,
                interactionInstructions: Color.primary,
                saveButton: Color.accentColor,
                background: colorScheme == .light
                    ? Color(UIColor.secondarySystemBackground)
                    : Color(UIColor.systemBackground),
                cropHandle: Color.primary
            )
        }
    }
}
