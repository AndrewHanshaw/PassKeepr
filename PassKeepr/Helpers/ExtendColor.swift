import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

extension Color {
    func toHex() -> UInt {
        let components = cgColor?.components ?? [0, 0, 0, 0] // Default to black if nil
        let red = UInt(components[0] * 255)
        let green = UInt(components[1] * 255)
        let blue = UInt(components[2] * 255)

        return (red << 16) + (green << 8) + blue
    }
}

extension Color {
    static func binding(from hexBinding: Binding<UInt>) -> Binding<Color> {
        Binding<Color>(
            get: {
                Color(hex: hexBinding.wrappedValue) // Convert UInt to Color
            },
            set: { newColor in
                hexBinding.wrappedValue = newColor.toHex() // Convert Color to UInt
            }
        )
    }
}
