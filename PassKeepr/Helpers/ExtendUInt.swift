extension UInt {
    func toRGBString() -> String {
        let red = (self >> 16) & 0xFF
        let green = (self >> 8) & 0xFF
        let blue = self & 0xFF
        return "rgb(\(red), \(green), \(blue))"
    }
}
