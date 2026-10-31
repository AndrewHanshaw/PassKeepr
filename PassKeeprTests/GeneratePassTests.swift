@testable import PassKeepr
import XCTest
import ZIPFoundation

final class GeneratePassTests: XCTestCase {
    var tempDirectory: URL!

    override func setUpWithError() throws {
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDirectory)
    }

    func testGeneratePassProducesValidPkpass() throws {
        var pass = PassObject()
        pass.description = "Test Pass"
        pass.barcodeString = "123456789"
        pass.barcodeType = .qr

        guard let pkpassURL = generatePass(passObject: pass, directory: tempDirectory) else {
            XCTFail("generatePass returned nil")
            return
        }

        XCTAssertTrue(FileManager.default.fileExists(atPath: pkpassURL.path))
        XCTAssertEqual(pkpassURL.pathExtension, "pkpass")

        let archive = try Archive(url: pkpassURL, accessMode: .read)

        let entryNames = archive.map { $0.path }
        XCTAssertTrue(entryNames.contains("pass.json"))
        // generatePass produces the unsigned package; manifest.json and the
        // signature are added by the signing server, so they are not expected here
        XCTAssertTrue(entryNames.contains("icon.png"))
    }

    func testGeneratePassIncludesBarcodeInPassJson() throws {
        var pass = PassObject()
        pass.description = "Barcode Test"
        pass.barcodeString = "CODE128DATA"
        pass.barcodeType = .code128

        guard let pkpassURL = generatePass(passObject: pass, directory: tempDirectory) else {
            XCTFail("generatePass returned nil")
            return
        }

        let archive = try Archive(url: pkpassURL, accessMode: .read)
        guard let entry = archive["pass.json"] else {
            XCTFail("pass.json not found in archive")
            return
        }

        var passJsonData = Data()
        _ = try archive.extract(entry, consumer: { passJsonData.append($0) })

        let json = try JSONSerialization.jsonObject(with: passJsonData) as? [String: Any]
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["description"] as? String, "Barcode Test")

        let barcode = json?["barcode"] as? [String: Any]
        XCTAssertEqual(barcode?["message"] as? String, "CODE128DATA")
    }
}
