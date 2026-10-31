@testable import PassKeepr
import XCTest

final class PersistenceTests: XCTestCase {
    func testPassKeeprDataRoundTrip() throws {
        var pass1 = PassObject()
        pass1.description = "Gym Membership"
        pass1.barcodeString = "GYM12345"
        pass1.barcodeType = .code128

        var pass2 = PassObject()
        pass2.description = "Library Card"
        pass2.barcodeString = "LIB98765"
        pass2.barcodeType = .qr

        let original = ModelData.PassKeeprData(
            passObjects: [pass1, pass2],
            tutorialStage: 3
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ModelData.PassKeeprData.self, from: data)

        XCTAssertEqual(decoded.passObjects.count, 2)
        XCTAssertEqual(decoded.passObjects[0].description, "Gym Membership")
        XCTAssertEqual(decoded.passObjects[0].barcodeString, "GYM12345")
        XCTAssertEqual(decoded.passObjects[1].description, "Library Card")
        XCTAssertEqual(decoded.tutorialStage, 3)
    }

    func testEmptyPassListRoundTrip() throws {
        let original = ModelData.PassKeeprData(passObjects: [], tutorialStage: 0)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ModelData.PassKeeprData.self, from: data)
        XCTAssertTrue(decoded.passObjects.isEmpty)
    }
}
