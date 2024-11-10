
extension UInt {
    func toRGBString(hex: UInt) -> String {
        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = hex & 0xFF
        return "rgb(\(red), \(green), \(blue))"
    }
}
