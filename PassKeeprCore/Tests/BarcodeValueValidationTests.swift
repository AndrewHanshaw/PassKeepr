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

    func testITFAcceptsEvenDigitCountsFromTwoToTwentySix() {
        for digitCount in stride(from: 2, through: 26, by: 2) {
            let value = String(repeating: "1", count: digitCount)
            XCTAssertTrue(BarcodeType.itf.isEnteredBarcodeValueValid(string: value), "\(digitCount) digits")
        }
        // A typical ITF-14
        XCTAssertTrue(BarcodeType.itf.isEnteredBarcodeValueValid(string: "12345678901231"))
    }

    func testITFRejectsOddDigitCounts() {
        for digitCount in stride(from: 1, through: 25, by: 2) {
            let value = String(repeating: "1", count: digitCount)
            XCTAssertFalse(BarcodeType.itf.isEnteredBarcodeValueValid(string: value), "\(digitCount) digits")
        }
    }

    func testITFRejectsEmptyTooLongAndNonDigits() {
        // 28 digits is even but over the 26 digit limit (the module count must fit in a UInt8)
        for value in ["", String(repeating: "1", count: 28), "12ab", "12 34", "12-34", "1234a6"] {
            XCTAssertFalse(BarcodeType.itf.isEnteredBarcodeValueValid(string: value), "\"\(value)\"")
        }
    }
}
