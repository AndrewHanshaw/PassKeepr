@testable import PassKeeprCore
import XCTest

final class BarcodeValueValidationTests: XCTestCase {
    func testEAN8AcceptsExactlyEightDigits() {
        XCTAssertTrue(BarcodeType.ean8.isEnteredBarcodeValueValid(string: "12345670"))
        XCTAssertTrue(BarcodeType.ean8.isEnteredBarcodeValueValid(string: "00000000"))
    }

    func testEAN8RejectsWrongLengthOrNonDigits() {
        for value in ["", "1234567", "123456789", "1234567a", "1234 567", "-1234567"] {
            XCTAssertFalse(BarcodeType.ean8.isEnteredBarcodeValueValid(string: value), "\"\(value)\"")
        }
    }
}
