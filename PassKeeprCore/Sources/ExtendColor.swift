import SwiftUI

public extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }

    func toHex() -> UInt {
        let resolved = resolve(in: EnvironmentValues())

        func channel(_ value: Float) -> UInt {
            UInt((min(1, max(0, value)) * 255).rounded())
        }

        return (channel(resolved.red) << 16) + (channel(resolved.green) << 8) + channel(resolved.blue)
    }

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

    // Nudges this color's brightness by `percentage`. Negative is darker, positive is lighter, clamped so it never goes below black or above white
    func adjustingBrightness(by percentage: Double) -> Color {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        UIColor(self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        let newBrightness = min(1, max(0, brightness + CGFloat(percentage)))
        return Color(hue: Double(hue), saturation: Double(saturation), brightness: Double(newBrightness), opacity: Double(alpha))
    }
}
