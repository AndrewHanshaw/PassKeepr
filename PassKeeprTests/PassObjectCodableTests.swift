@testable import PassKeepr
import XCTest

final class PassObjectCodableTests: XCTestCase {
    func testRoundTripPreservesAllFields() throws {
        var original = PassObject()
        original.description = "Test Pass"
        original.barcodeString = "123456789"
        original.barcodeType = .qr
        original.primaryFieldLabel = "Member"
        original.primaryFieldText = "John Doe"
        original.backgroundColor = 0xFF0000
        original.foregroundColor = 0x00FF00
        original.labelColor = 0x0000FF
        original.wifiSSID = "TestNetwork"
        original.wifiPassword = "secret123"

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PassObject.self, from: data)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.description, original.description)
        XCTAssertEqual(decoded.barcodeString, original.barcodeString)
        XCTAssertEqual(decoded.barcodeType, original.barcodeType)
        XCTAssertEqual(decoded.primaryFieldLabel, original.primaryFieldLabel)
        XCTAssertEqual(decoded.primaryFieldText, original.primaryFieldText)
        XCTAssertEqual(decoded.backgroundColor, original.backgroundColor)
        XCTAssertEqual(decoded.foregroundColor, original.foregroundColor)
        XCTAssertEqual(decoded.labelColor, original.labelColor)
        XCTAssertEqual(decoded.wifiSSID, original.wifiSSID)
        XCTAssertEqual(decoded.wifiPassword, original.wifiPassword)
    }

    func testDefaultInitProvidesSaneDefaults() {
        let pass = PassObject()
        XCTAssertEqual(pass.barcodeType, .none)
        XCTAssertEqual(pass.barcodeString, "")
        XCTAssertEqual(pass.group, 1)
    }

    func testDecodingMinimalJSONUsesDefaults() throws {
        let json = #"{"description": "Minimal"}"#.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(PassObject.self, from: json)
        XCTAssertEqual(decoded.description, "Minimal")
        XCTAssertEqual(decoded.barcodeType, .none)
        XCTAssertFalse(decoded.id.uuidString.isEmpty)
    }
}
