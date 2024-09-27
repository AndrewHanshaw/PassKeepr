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
        @Environment(\.self) var environment
        let resolvedColor = resolve(in: environment)

        let red = UInt(resolvedColor.red * 255)
        let green = UInt(resolvedColor.green * 255)
        let blue = UInt(resolvedColor.blue * 255)

        return (red << 16) + (green << 8) + blue
    }
}
