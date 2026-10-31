@testable import PassKeepr
import XCTest

final class VCardQrCodeTests: XCTestCase {
    func testFormatVCardProducesValidStructure() {
        let result = VCardQrCode.formatVCard(
            firstName: "John",
            lastName: "Doe",
            company: "Acme",
            phone: "555-1234",
            email: "john@example.com",
            url: "",
            address: "",
            birthday: nil,
            social: "",
            customFields: []
        )

        XCTAssertTrue(result.hasPrefix("BEGIN:VCARD\nVERSION:3.0"))
        XCTAssertTrue(result.hasSuffix("END:VCARD"))
        XCTAssertTrue(result.contains("N:Doe;John;;;"))
        XCTAssertTrue(result.contains("FN:John Doe"))
        XCTAssertTrue(result.contains("ORG:Acme"))
        XCTAssertTrue(result.contains("TEL;TYPE=CELL:555-1234"))
        XCTAssertTrue(result.contains("EMAIL:john@example.com"))
    }

    func testFormatVCardOmitsEmptyFields() {
        let result = VCardQrCode.formatVCard(
            firstName: "Jane",
            lastName: "",
            company: "",
            phone: "",
            email: "",
            url: "",
            address: "",
            birthday: nil,
            social: "",
            customFields: []
        )

        XCTAssertFalse(result.contains("ORG:"))
        XCTAssertFalse(result.contains("TEL;"))
        XCTAssertFalse(result.contains("EMAIL:"))
        XCTAssertTrue(result.contains("FN:Jane"))
    }

    func testFormatVCardIncludesBirthday() throws {
        var components = DateComponents()
        components.year = 1990
        components.month = 5
        components.day = 15
        let birthday = try XCTUnwrap(Calendar.current.date(from: components))

        let result = VCardQrCode.formatVCard(
            firstName: "Bob",
            lastName: "Smith",
            company: "",
            phone: "",
            email: "",
            url: "",
            address: "",
            birthday: birthday,
            social: "",
            customFields: []
        )

        XCTAssertTrue(result.contains("BDAY:19900515"))
    }
}
