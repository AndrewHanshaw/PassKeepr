@testable import PassKeeprCore
import XCTest
import ZIPFoundation

/// Snapshot-style tests for `generatePass`. Each test builds one fully static
/// PassObject fixture, generates the unsigned package, and asserts the
/// complete contents: the pass.json data and the exact set of image files.
///
/// Where GeneratePassDesignRulesTests checks individual design rules, these
/// fixtures pin the whole output for pass shapes chosen to hit edge cases and
/// branches in the generator. Fixtures pin `id` so the serialNumber is
/// deterministic, and use generated PNGs of fixed sizes so the saved image
/// variant file sets are deterministic too.
final class GeneratePassFixtureTests: XCTestCase {
    /// Top-level keys every fixture emits, with the style key as a placeholder.
    private let baseTopLevelKeys: Set<String> = [
        "formatVersion", "teamIdentifier", "organizationName", "description",
        "passTypeIdentifier", "serialNumber", "foregroundColor", "backgroundColor",
        "labelColor", "associatedStoreIdentifiers", "userInfo",
    ]

    var tempDirectory: URL!

    override func setUpWithError() throws {
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDirectory)
    }

    // MARK: - Baseline fixtures

    /// The untouched default pass: required keys only, a primary field with
    /// empty label and value, and the bundled default icon (1940x1940, so it
    /// is classified 3x and downscaled, producing all three icon variants).
    func testDefaultPass() throws {
        var pass = PassObject()
        pass.id = try uuid("00000000-0000-0000-0000-000000000001")

        let (json, files) = try generatePackage(from: pass)

        XCTAssertEqual(Set(json.keys), baseTopLevelKeys.union(["generic"]))
        XCTAssertEqual((json["formatVersion"] as? NSNumber)?.intValue, 1)
        XCTAssertEqual(json["teamIdentifier"] as? String, "NZDS56Z4Q9")
        XCTAssertEqual(json["organizationName"] as? String, "PassKeepr")
        XCTAssertEqual(json["description"] as? String, "PassKeepr Pass")
        XCTAssertEqual(json["passTypeIdentifier"] as? String, "pass.com.hanshaw.passKeepr.1")
        XCTAssertEqual(json["serialNumber"] as? String, pass.id.uuidString)
        XCTAssertEqual(json["foregroundColor"] as? String, "rgb(0, 0, 0)")
        XCTAssertEqual(json["backgroundColor"] as? String, "rgb(255, 255, 255)")
        XCTAssertEqual(json["labelColor"] as? String, "rgb(0, 0, 0)")
        XCTAssertEqual(storeIdentifiers(in: json), [6_740_440_736])
        XCTAssertNil(json["barcode"])

        let generic = try XCTUnwrap(json["generic"] as? [String: Any])
        XCTAssertEqual(Set(generic.keys), ["primaryFields"])
        XCTAssertEqual(generic["primaryFields"] as? NSArray, [
            ["key": "primary", "label": "", "value": ""],
        ] as NSArray)

        XCTAssertEqual(Set(files.keys), ["pass.json", "icon.png", "icon@2x.png", "icon@3x.png"])
    }

    /// Every lever populated at once: the golden master for a generic pass.
    func testKitchenSinkGenericPass() throws {
        var pass = PassObject()
        pass.id = try uuid("00000000-0000-0000-0000-000000000002")
        pass.description = "Gym membership card for Ada Lovelace"
        pass.passIcon = pngData(width: 300, height: 300)
        pass.logoImage = pngData(width: 800, height: 200)
        pass.thumbnailImage = pngData(width: 300, height: 300)
        pass.foregroundColor = 0x111111
        pass.backgroundColor = 0x3366FF
        pass.labelColor = 0xEEEEEE
        pass.primaryFieldLabel = "Member"
        pass.primaryFieldText = "Ada Lovelace"
        pass.headerFieldOneLabel = "Points"
        pass.headerFieldOneText = "1,250"
        pass.isHeaderFieldTwoOn = true
        pass.headerFieldTwoLabel = "Tier"
        pass.headerFieldTwoText = "Gold"
        pass.secondaryFieldOneLabel = "Name"
        pass.secondaryFieldOneText = "Ada Lovelace"
        pass.isSecondaryFieldTwoOn = true
        pass.secondaryFieldTwoLabel = "Since"
        pass.secondaryFieldTwoText = "2020"
        pass.isSecondaryFieldThreeOn = true
        pass.secondaryFieldThreeLabel = "Level"
        pass.secondaryFieldThreeText = "3"
        pass.auxiliaryFieldOneLabel = "Store"
        pass.auxiliaryFieldOneText = "Main Street"
        pass.isAuxiliaryFieldTwoOn = true
        pass.auxiliaryFieldTwoLabel = "Aisle"
        pass.auxiliaryFieldTwoText = "4"
        pass.isAuxiliaryFieldThreeOn = true
        pass.auxiliaryFieldThreeLabel = "Gate"
        pass.auxiliaryFieldThreeText = "7"
        pass.barcodeType = .qr
        pass.barcodeString = "GYM-MEMBER-0042"
        pass.altText = "0042"
        pass.hasExpirationDate = true
        pass.expirationDate = Date(timeIntervalSince1970: 1_893_456_000)
        pass.associatedStoreIdentifiers = [111, 222]
        pass.locations = [
            PassLocation(latitude: 37.331, longitude: -122.029, relevantText: "Main Street gym"),
            PassLocation(latitude: 37.4, longitude: -122.1, relevantText: ""),
            PassLocation(latitude: 37.5, longitude: -122.2, relevantText: ""),
        ]

        let (json, files) = try generatePackage(from: pass)

        XCTAssertEqual(Set(json.keys), baseTopLevelKeys.union(["generic", "barcode", "expirationDate", "locations"]))
        XCTAssertEqual(json["description"] as? String, "Gym membership card for Ada Lovelace")
        XCTAssertEqual(json["foregroundColor"] as? String, "rgb(17, 17, 17)")
        XCTAssertEqual(json["backgroundColor"] as? String, "rgb(51, 102, 255)")
        XCTAssertEqual(json["labelColor"] as? String, "rgb(238, 238, 238)")
        XCTAssertEqual(storeIdentifiers(in: json), [111, 222])

        let generic = try XCTUnwrap(json["generic"] as? [String: Any])
        XCTAssertEqual(Set(generic.keys), ["headerFields", "primaryFields", "secondaryFields", "auxiliaryFields"])
        XCTAssertEqual(generic["headerFields"] as? NSArray, [
            ["key": "header1", "label": "Points", "value": "1,250"],
            ["key": "header2", "label": "Tier", "value": "Gold"],
        ] as NSArray)
        XCTAssertEqual(generic["primaryFields"] as? NSArray, [
            ["key": "primary", "label": "Member", "value": "Ada Lovelace"],
        ] as NSArray)
        XCTAssertEqual(generic["secondaryFields"] as? NSArray, [
            ["key": "secondary1", "label": "Name", "value": "Ada Lovelace"],
            ["key": "secondary2", "label": "Since", "value": "2020"],
            ["key": "secondary3", "label": "Level", "value": "3"],
        ] as NSArray)
        XCTAssertEqual(generic["auxiliaryFields"] as? NSArray, [
            ["key": "auxiliary1", "label": "Store", "value": "Main Street"],
            ["key": "auxiliary2", "label": "Aisle", "value": "4"],
            ["key": "auxiliary3", "label": "Gate", "value": "7"],
        ] as NSArray)

        XCTAssertEqual(json["barcode"] as? NSDictionary, [
            "message": "GYM-MEMBER-0042",
            "format": "PKBarcodeFormatQR",
            "messageEncoding": "us-ascii",
            "altText": "0042",
        ] as NSDictionary)

        let expiration = try XCTUnwrap(json["expirationDate"] as? String)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        XCTAssertEqual(formatter.date(from: expiration), pass.expirationDate)

        let locations = try XCTUnwrap(json["locations"] as? [[String: Any]])
        XCTAssertEqual(locations.count, 3)
        XCTAssertEqual((locations[0]["latitude"] as? NSNumber)?.doubleValue, 37.331)
        XCTAssertEqual((locations[0]["longitude"] as? NSNumber)?.doubleValue, -122.029)
        XCTAssertEqual(locations[0]["relevantText"] as? String, "Main Street gym")
        XCTAssertNil(locations[1]["relevantText"])
        XCTAssertNil(locations[2]["relevantText"])

        XCTAssertEqual(Set(files.keys), [
            "pass.json",
            "icon.png", "icon@2x.png", "icon@3x.png",
            "logo.png", "logo@2x.png", "logo@3x.png",
            "thumbnail.png", "thumbnail@2x.png", "thumbnail@3x.png",
        ])
    }

    // MARK: - Style and image fixtures

    /// Background image takes priority for the style, so this comes out as an
    /// eventTicket; the background image is saved and the strip image is
    /// dropped because both are set.
    func testStripPlusBackgroundPass() throws {
        var pass = PassObject()
        pass.id = try uuid("00000000-0000-0000-0000-000000000003")
        pass.passIcon = pngData(width: 300, height: 300)
        pass.barcodeType = .code128
        pass.barcodeString = "123456789012"
        pass.isCustomStripImageOn = true
        pass.stripImage = pngData(width: 600, height: 200)
        pass.backgroundImage = pngData(width: 300, height: 400)

        let (json, files) = try generatePackage(from: pass)

        XCTAssertEqual(Set(json.keys), baseTopLevelKeys.union(["eventTicket", "barcode"]))
        let eventTicket = try XCTUnwrap(json["eventTicket"] as? [String: Any])
        XCTAssertTrue(eventTicket.isEmpty)
        XCTAssertEqual(json["barcode"] as? NSDictionary, [
            "message": "123456789012",
            "format": "PKBarcodeFormatCode128",
            "messageEncoding": "iso-8859-1",
        ] as NSDictionary)

        XCTAssertEqual(Set(files.keys), [
            "pass.json", "icon.png", "icon@2x.png", "icon@3x.png", "background.png",
        ])
    }

    /// A custom strip image forces the storeCard style even when a thumbnail
    /// is set, suppresses the primary and auxiliary fields, and is saved even
    /// though the barcode string is empty.
    func testCustomStripImagePass() throws {
        var pass = PassObject()
        pass.id = try uuid("00000000-0000-0000-0000-000000000004")
        pass.passIcon = pngData(width: 300, height: 300)
        pass.isCustomStripImageOn = true
        pass.stripImage = pngData(width: 600, height: 200)
        pass.thumbnailImage = pngData(width: 300, height: 300)
        pass.primaryFieldLabel = "Member"
        pass.primaryFieldText = "Ada"
        pass.auxiliaryFieldOneLabel = "Store"
        pass.auxiliaryFieldOneText = "Main Street"
        pass.barcodeType = .qr
        pass.barcodeString = ""

        let (json, files) = try generatePackage(from: pass)

        XCTAssertEqual(Set(json.keys), baseTopLevelKeys.union(["storeCard"]))
        XCTAssertNil(json["barcode"])
        let storeCard = try XCTUnwrap(json["storeCard"] as? [String: Any])
        XCTAssertTrue(storeCard.isEmpty)

        XCTAssertEqual(Set(files.keys), [
            "pass.json", "icon.png", "icon@2x.png", "icon@3x.png", "strip.png",
        ])
    }

    /// A background image only counts for code128, pdf417, qr, and none
    /// barcode types, so a code93 pass stays generic and the image is not
    /// saved.
    func testBackgroundImageWithCode93Pass() throws {
        var pass = PassObject()
        pass.id = try uuid("00000000-0000-0000-0000-000000000005")
        pass.passIcon = pngData(width: 300, height: 300)
        pass.backgroundImage = pngData(width: 300, height: 400)
        pass.barcodeType = .code93
        pass.barcodeString = "CODE93DATA"

        let (json, files) = try generatePackage(from: pass)

        XCTAssertEqual(Set(json.keys), baseTopLevelKeys.union(["generic"]))
        XCTAssertNil(json["barcode"])
        let generic = try XCTUnwrap(json["generic"] as? [String: Any])
        XCTAssertEqual(Set(generic.keys), ["primaryFields"])
        XCTAssertEqual(generic["primaryFields"] as? NSArray, [
            ["key": "primary", "label": "", "value": ""],
        ] as NSArray)

        XCTAssertEqual(Set(files.keys), ["pass.json", "icon.png", "icon@2x.png", "icon@3x.png"])
    }

    /// One pass exercising all three image size classes: a below-1x icon
    /// (saved as-is, no variants), a 2x-class logo (original saved as @2x
    /// plus a derived 1x at half size), and an oversized thumbnail
    /// (downscaled to the 3x cap plus derived @2x and 1x).
    func testImageVariantClassificationPass() throws {
        var pass = PassObject()
        pass.id = try uuid("00000000-0000-0000-0000-000000000006")
        pass.passIcon = pngData(width: 20, height: 20)
        pass.logoImage = pngData(width: 200, height: 60)
        pass.thumbnailImage = pngData(width: 1000, height: 1000)

        let (json, files) = try generatePackage(from: pass)

        XCTAssertEqual(Set(json.keys), baseTopLevelKeys.union(["generic"]))
        XCTAssertEqual(Set(files.keys), [
            "pass.json",
            "icon.png",
            "logo.png", "logo@2x.png",
            "thumbnail.png", "thumbnail@2x.png", "thumbnail@3x.png",
        ])

        XCTAssertEqual(try pixelSize(of: XCTUnwrap(files["icon.png"])), Size(width: 20, height: 20))
        XCTAssertEqual(try pixelSize(of: XCTUnwrap(files["logo@2x.png"])), Size(width: 200, height: 60))
        XCTAssertEqual(try pixelSize(of: XCTUnwrap(files["logo.png"])), Size(width: 100, height: 30))
        XCTAssertEqual(try pixelSize(of: XCTUnwrap(files["thumbnail@3x.png"])), Size(width: 270, height: 270))
        XCTAssertEqual(try pixelSize(of: XCTUnwrap(files["thumbnail.png"])), Size(width: 90, height: 90))
    }

    // MARK: - Field fixtures

    /// Turning on only the third secondary field cascades: all three fields
    /// are emitted, with empty labels and single-space values where the text
    /// is empty.
    func testSecondaryCascadePass() throws {
        var pass = PassObject()
        pass.id = try uuid("00000000-0000-0000-0000-000000000007")
        pass.isSecondaryFieldThreeOn = true

        let (json, _) = try generatePackage(from: pass)

        let generic = try XCTUnwrap(json["generic"] as? [String: Any])
        XCTAssertEqual(Set(generic.keys), ["primaryFields", "secondaryFields"])
        XCTAssertEqual(generic["secondaryFields"] as? NSArray, [
            ["key": "secondary1", "label": "", "value": " "],
            ["key": "secondary2", "label": "", "value": " "],
            ["key": "secondary3", "label": "", "value": " "],
        ] as NSArray)
    }

    /// With header field one left blank, enabling header field two produces
    /// a single header field, keyed header2.
    func testHeaderFieldTwoOnlyPass() throws {
        var pass = PassObject()
        pass.id = try uuid("00000000-0000-0000-0000-000000000008")
        pass.isHeaderFieldTwoOn = true
        pass.headerFieldTwoLabel = "Tier"
        pass.headerFieldTwoText = "Gold"

        let (json, _) = try generatePackage(from: pass)

        let generic = try XCTUnwrap(json["generic"] as? [String: Any])
        XCTAssertEqual(Set(generic.keys), ["primaryFields", "headerFields"])
        XCTAssertEqual(generic["headerFields"] as? NSArray, [
            ["key": "header2", "label": "Tier", "value": "Gold"],
        ] as NSArray)
    }

    // MARK: - Barcode and data fixtures

    /// EAN-13 is rendered as an image by the app rather than as a PassKit
    /// barcode, so the JSON has no barcode at all; the rendered barcode lives
    /// in the strip image, which makes the pass a storeCard.
    func testEAN13ImageBarcodePass() throws {
        var pass = PassObject()
        pass.id = try uuid("00000000-0000-0000-0000-000000000009")
        pass.passIcon = pngData(width: 300, height: 300)
        pass.barcodeType = .ean13
        pass.barcodeString = "4006381333931"
        pass.stripImage = pngData(width: 600, height: 200)

        let (json, files) = try generatePackage(from: pass)

        XCTAssertEqual(Set(json.keys), baseTopLevelKeys.union(["storeCard"]))
        XCTAssertNil(json["barcode"])
        let storeCard = try XCTUnwrap(json["storeCard"] as? [String: Any])
        XCTAssertTrue(storeCard.isEmpty)

        XCTAssertEqual(Set(files.keys), [
            "pass.json", "icon.png", "icon@2x.png", "icon@3x.png", "strip.png",
        ])
    }

    /// Apple caps relevant locations at ten per pass, so a PassObject
    /// holding eleven locations emits only the first ten, in order.
    func testLocationsCappedAtTenPass() throws {
        var pass = PassObject()
        pass.id = try uuid("00000000-0000-0000-0000-000000000010")
        pass.locations = (0 ..< 11).map { index in
            PassLocation(latitude: 37.0 + Double(index), longitude: -122.0 - Double(index), relevantText: "")
        }

        let (json, _) = try generatePackage(from: pass)

        XCTAssertEqual(Set(json.keys), baseTopLevelKeys.union(["generic", "locations"]))
        let locations = try XCTUnwrap(json["locations"] as? [[String: Any]])
        XCTAssertEqual(locations.count, 10)
        for (index, location) in locations.enumerated() {
            XCTAssertEqual((location["latitude"] as? NSNumber)?.doubleValue, 37.0 + Double(index))
            XCTAssertEqual((location["longitude"] as? NSNumber)?.doubleValue, -122.0 - Double(index))
            XCTAssertNil(location["relevantText"])
        }
    }

    /// Non-English text round-trips exactly, and a QR encoding chosen
    /// explicitly (rather than reached by fallback) is what lands in the
    /// barcode's messageEncoding.
    func testUnicodePass() throws {
        var pass = PassObject()
        pass.id = try uuid("00000000-0000-0000-0000-000000000011")
        pass.description = "ジムのメンバーカード"
        pass.primaryFieldLabel = "名前"
        pass.primaryFieldText = "山田太郎"
        pass.barcodeType = .qr
        pass.barcodeString = "member-yamada"
        pass.qrCodeEncoding = .unicode

        let (json, _) = try generatePackage(from: pass)

        XCTAssertEqual(Set(json.keys), baseTopLevelKeys.union(["generic", "barcode"]))
        XCTAssertEqual(json["description"] as? String, "ジムのメンバーカード")
        let generic = try XCTUnwrap(json["generic"] as? [String: Any])
        XCTAssertEqual(generic["primaryFields"] as? NSArray, [
            ["key": "primary", "label": "名前", "value": "山田太郎"],
        ] as NSArray)
        XCTAssertEqual(json["barcode"] as? NSDictionary, [
            "message": "member-yamada",
            "format": "PKBarcodeFormatQR",
            "messageEncoding": "utf-16",
        ] as NSDictionary)
    }

    /// An empty description is emitted as-is; the generator does not
    /// substitute the default or reject the pass.
    func testEmptyDescriptionPass() throws {
        var pass = PassObject()
        pass.id = try uuid("00000000-0000-0000-0000-000000000012")
        pass.description = ""

        let (json, files) = try generatePackage(from: pass)

        XCTAssertEqual(Set(json.keys), baseTopLevelKeys.union(["generic"]))
        XCTAssertEqual(json["description"] as? String, "")
        XCTAssertEqual(Set(files.keys), ["pass.json", "icon.png", "icon@2x.png", "icon@3x.png"])
    }

    // MARK: - Helpers

    private struct Size: Equatable {
        let width: Int
        let height: Int
    }

    /// Runs generatePass and returns the parsed pass.json plus every file in
    /// the package, keyed by entry name.
    private func generatePackage(from pass: PassObject) throws -> (json: [String: Any], files: [String: Data]) {
        let pkpassURL = try XCTUnwrap(
            generatePass(passObject: pass, directory: tempDirectory),
            "generatePass returned nil"
        )
        let archive = try Archive(url: pkpassURL, accessMode: .read)

        var files: [String: Data] = [:]
        for entry in archive {
            var data = Data()
            _ = try archive.extract(entry, consumer: { data.append($0) })
            files[entry.path] = data
        }

        let passJSONData = try XCTUnwrap(files["pass.json"], "Package has no pass.json")
        let json = try XCTUnwrap(
            JSONSerialization.jsonObject(with: passJSONData) as? [String: Any],
            "pass.json is not a JSON object"
        )
        return (json, files)
    }

    private func uuid(_ string: String) throws -> UUID {
        try XCTUnwrap(UUID(uuidString: string), "Invalid fixture UUID: \(string)")
    }

    private func storeIdentifiers(in json: [String: Any]) -> [Int] {
        (json["associatedStoreIdentifiers"] as? [Any])?
            .compactMap { ($0 as? NSNumber)?.intValue } ?? []
    }

    private func pngData(width: Int, height: Int) -> Data {
        TestImages.redPNG(width: width, height: height)
    }

    private func pixelSize(of data: Data) -> Size? {
        guard let size = TestImages.pixelSize(of: data) else { return nil }
        return Size(width: size.width, height: size.height)
    }
}
