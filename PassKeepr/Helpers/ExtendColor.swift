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

    func toHex() -> UInt {
        let components = cgColor?.components ?? [0, 0, 0, 0] // Default to black if nil
        let red = UInt(components[0] * 255)
        let green = UInt(components[1] * 255)
        let blue = UInt(components[2] * 255)

        return (red << 16) + (green << 8) + blue
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

    // Returns black (0x000000) or white (0xFFFFFF), whichever is more legible on the given
    // background colour. Uses the same luminance weighting as UIImage.averageBrightness().
    static func legibleTextColor(onBackground hex: UInt) -> UInt {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        let luminance = (0.299 * red) + (0.587 * green) + (0.114 * blue)
        return luminance > 0.6 ? 0x000000 : 0xFFFFFF
    }

    // WCAG relative luminance of a packed 0xRRGGBB colour.
    static func relativeLuminance(_ hex: UInt) -> Double {
        func channel(_ raw: UInt) -> Double {
            let c = Double(raw) / 255.0
            return c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * channel((hex >> 16) & 0xFF)
            + 0.7152 * channel((hex >> 8) & 0xFF)
            + 0.0722 * channel(hex & 0xFF)
    }

    // WCAG contrast ratio between two colours (1 = identical, 21 = black-on-white).
    static func contrastRatio(_ a: UInt, _ b: UInt) -> Double {
        let lighter = max(relativeLuminance(a), relativeLuminance(b))
        let darker = min(relativeLuminance(a), relativeLuminance(b))
        return (lighter + 0.05) / (darker + 0.05)
    }
}

extension UIColor {
    convenience init(hex: UInt, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }

    // Convert to the same packed 0xRRGGBB UInt representation used for the pass colours.
    func toUInt() -> UInt {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let r = UInt((max(0, min(1, red)) * 255).rounded())
        let g = UInt((max(0, min(1, green)) * 255).rounded())
        let b = UInt((max(0, min(1, blue)) * 255).rounded())
        return (r << 16) + (g << 8) + b
    }
}
