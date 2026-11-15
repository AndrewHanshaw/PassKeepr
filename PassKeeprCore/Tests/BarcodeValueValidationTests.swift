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

    // The generators only encode ASCII digits, so non-ASCII numerals (e.g. from a localized number pad) must be rejected.
    func testDigitOnlyTypesRejectNonASCIIDigits() {
        let arabicIndic = "٠١٢٣٤٥٦٧٨٩"
        let fullwidth = "０１２３４５６７８９"
        let cases: [(BarcodeType, Int)] = [(.upce, 6), (.upca, 12), (.ean13, 13), (.ean8, 8), (.itf, 14)]
        for (type, length) in cases {
            for digits in [arabicIndic, fullwidth] {
                let value = String((digits + digits).prefix(length))
                XCTAssertFalse(type.isEnteredBarcodeValueValid(string: value), "\(type) accepted \"\(value)\"")
            }
        }
    }

    func testNormalizingDigitsConvertsOtherScriptsToASCII() {
        XCTAssertEqual("٠١٢٣٤٥٦٧٨٩".normalizingDigitsToASCII(), "0123456789") // Arabic-Indic
        XCTAssertEqual("۰۱۲۳۴۵۶۷۸۹".normalizingDigitsToASCII(), "0123456789") // Extended Arabic-Indic (Persian)
        XCTAssertEqual("०१२३४५६७८९".normalizingDigitsToASCII(), "0123456789") // Devanagari
        XCTAssertEqual("０１２３４５６７８９".normalizingDigitsToASCII(), "0123456789") // Fullwidth
    }

    func testNormalizingDigitsLeavesEverythingElseAlone() {
        for value in ["", "0123456789", "ABC-123 xyz", "½²", "日本語"] {
            XCTAssertEqual(value.normalizingDigitsToASCII(), value)
        }
        XCTAssertEqual("ab١٢-cd".normalizingDigitsToASCII(), "ab12-cd")
    }

    func testOnlyQRAndNoneAcceptNonASCII() {
        for type in BarcodeType.allCases {
            XCTAssertEqual(type.acceptsOnlyASCII, type != .qr && type != .none, "\(type)")
        }
        XCTAssertFalse(BarcodeType.code128.isEnteredBarcodeValueValid(string: "é"))
        XCTAssertFalse(BarcodeType.pdf417.isEnteredBarcodeValueValid(string: "é"))
        XCTAssertTrue(BarcodeType.qr.isEnteredBarcodeValueValid(string: "é"))
    }

    func testNormalizedLocalizedDigitsAreValid() {
        XCTAssertTrue(BarcodeType.ean8.isEnteredBarcodeValueValid(string: "١٢٣٤٥٦٧٠".normalizingDigitsToASCII()))
        XCTAssertTrue(BarcodeType.itf.isEnteredBarcodeValueValid(string: "１２３４５６７８９０１２３１".normalizingDigitsToASCII()))
    }
}
