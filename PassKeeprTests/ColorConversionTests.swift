@testable import PassKeepr
import SwiftUI
import XCTest

final class ColorConversionTests: XCTestCase {
    func testHexToColorRoundTrip() {
        let original: UInt = 0x1A2B3C
        let color = Color(hex: original)
        XCTAssertEqual(color.toHex(), original)
    }

    func testHexToColorBlack() {
        let color = Color(hex: 0x000000)
        XCTAssertEqual(color.toHex(), 0x000000)
    }

    func testHexToColorWhite() {
        let color = Color(hex: 0xFFFFFF)
        XCTAssertEqual(color.toHex(), 0xFFFFFF)
    }

    func testUIntToRGBString() {
        XCTAssertEqual(UInt(0xFF0000).toRGBString(), "rgb(255, 0, 0)")
        XCTAssertEqual(UInt(0x00FF00).toRGBString(), "rgb(0, 255, 0)")
        XCTAssertEqual(UInt(0x0000FF).toRGBString(), "rgb(0, 0, 255)")
    }
}
