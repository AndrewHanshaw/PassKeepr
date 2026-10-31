@testable import PassKeepr
import UIKit
import XCTest
import ZIPFoundation

// Tests that the packages produced by `generatePass` follow the pass design rules in Apple's Wallet Developer Guide:
// https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/PassKit_PG/Creating.html

// `generatePass` produces the unsigned package (pass.json plus images, zipped)
// The manifest.json and signature described by the guide are added afterwards by the signing server
// so they are out of scope for these tests.
final class GeneratePassDesignRulesTests: XCTestCase {
    private let styleKeys = ["boardingPass", "coupon", "eventTicket", "generic", "storeCard"]

    var tempDirectory: URL!

    override func setUpWithError() throws {
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDirectory)
    }

    func testRequiredTopLevelKeys() throws {
        var pass = PassObject()
        pass.description = "Membership card for Ada Lovelace"

        let (json, _) = try generatePackage(from: pass)

        XCTAssertEqual((json["formatVersion"] as? NSNumber)?.intValue, 1)
        XCTAssertEqual(json["organizationName"] as? String, "PassKeepr")
        let teamIdentifier = try XCTUnwrap(json["teamIdentifier"] as? String)
        XCTAssertFalse(teamIdentifier.isEmpty)
        XCTAssertEqual(json["description"] as? String, "Membership card for Ada Lovelace")
    }

    func testPassTypeIdentifierBeginsWithPassPrefix() throws {
        let pass = PassObject()

        let (json, _) = try generatePackage(from: pass)

        let identifier = try XCTUnwrap(json["passTypeIdentifier"] as? String)
        XCTAssertTrue(identifier.hasPrefix("pass."))
        XCTAssertEqual(identifier, "pass.com.hanshaw.passKeepr.\(pass.group)")
    }

    func testSerialNumberUniquelyIdentifiesPass() throws {
        let first = PassObject()
        let second = PassObject()

        let (firstJSON, _) = try generatePackage(from: first)
        let (secondJSON, _) = try generatePackage(from: second)

        XCTAssertEqual(firstJSON["serialNumber"] as? String, first.id.uuidString)
        XCTAssertEqual(secondJSON["serialNumber"] as? String, second.id.uuidString)
        XCTAssertNotEqual(firstJSON["serialNumber"] as? String, secondJSON["serialNumber"] as? String)
    }

    func testAssociatedStoreIdentifiersPassThrough() throws {
        var pass = PassObject()
        pass.associatedStoreIdentifiers = [123_456_789]

        let (json, _) = try generatePackage(from: pass)

        let identifiers = (json["associatedStoreIdentifiers"] as? [Any])?
            .compactMap { ($0 as? NSNumber)?.intValue }
        XCTAssertEqual(identifiers, [123_456_789])
    }

    func testExactlyOnePassStyleKey() throws {
        let pass = PassObject()

        let (json, _) = try generatePackage(from: pass)

        let presentStyles = styleKeys.filter { json[$0] != nil }
        XCTAssertEqual(presentStyles.count, 1)
        let style = try XCTUnwrap(json[presentStyles[0]] as? [String: Any])
        XCTAssertFalse(style.isEmpty)
    }

    func testDefaultStyleIsGeneric() throws {
        let pass = PassObject()

        let (json, _) = try generatePackage(from: pass)

        XCTAssertEqual(styleKey(in: json), "generic")
    }

    func testStripImageSelectsStoreCard() throws {
        var pass = PassObject()
        // EAN-13 isn't natively supported by PassKit, so it's rendered into the strip image
        pass.barcodeType = .ean13
        pass.barcodeString = "1234567890123"
        pass.stripImage = pngData(width: 600, height: 200)

        let (json, files) = try generatePackage(from: pass)

        XCTAssertEqual(styleKey(in: json), "storeCard")
        XCTAssertNotNil(files["strip.png"])
        // The generator suppresses the primary field when a strip image is used
        XCTAssertNil(styleFields(json, "primaryFields").first)
    }

    func testStripAndThumbnailSelectsGeneric() throws {
        var pass = PassObject()
        pass.barcodeType = .code128
        pass.barcodeString = "123456789012"
        pass.stripImage = pngData(width: 600, height: 200)
        pass.thumbnailImage = pngData(width: 300, height: 300)

        let (json, files) = try generatePackage(from: pass)

        XCTAssertEqual(styleKey(in: json), "generic")
        XCTAssertNotNil(files["thumbnail.png"])
    }

    func testBackgroundImageSelectsEventTicket() throws {
        var pass = PassObject()
        pass.backgroundImage = pngData(width: 300, height: 400)

        let (json, files) = try generatePackage(from: pass)

        XCTAssertEqual(styleKey(in: json), "eventTicket")
        XCTAssertNotNil(files["background.png"])
    }

    // The guide's style table: for event tickets, if you specify a strip image, do not specify a background image or a thumbnail.
    // The generator drops the strip image when both are set, so a package never contains both a strip image and a background image.
    func testPackageNeverContainsBothStripAndBackground() throws {
        var pass = PassObject()
        pass.barcodeType = .code128
        pass.barcodeString = "123456789012"
        pass.backgroundImage = pngData(width: 300, height: 400)
        pass.stripImage = pngData(width: 600, height: 200)

        let (_, files) = try generatePackage(from: pass)

        XCTAssertNotNil(files["background.png"])
        XCTAssertNil(files["strip.png"])
    }

    func testFieldsHaveKeyLabelAndValue() throws {
        let pass = fullyPopulatedPass()

        let (json, _) = try generatePackage(from: pass)

        let fields = allFields(in: json)
        XCTAssertFalse(fields.isEmpty)
        for field in fields {
            let key = try XCTUnwrap(field["key"] as? String)
            XCTAssertFalse(key.isEmpty)
            XCTAssertNotNil(field["label"], "Field \(key) is missing a label")
            XCTAssertNotNil(field["value"], "Field \(key) is missing a value")
        }
    }

    func testFieldKeysAreUnique() throws {
        let pass = fullyPopulatedPass()

        let (json, _) = try generatePackage(from: pass)

        let keys = allFields(in: json).compactMap { $0["key"] as? String }
        XCTAssertEqual(Set(keys).count, keys.count)
    }

    // The guide caps front fields at 3 header, 1 primary, 4 secondary and 4 auxiliary fields for generic passes.
    func testFrontFieldCountsWithinStyleLimits() throws {
        let pass = fullyPopulatedPass()

        let (json, _) = try generatePackage(from: pass)

        let header = styleFields(json, "headerFields")
        let primary = styleFields(json, "primaryFields")
        let secondary = styleFields(json, "secondaryFields")
        let auxiliary = styleFields(json, "auxiliaryFields")

        XCTAssertFalse(header.isEmpty)
        XCTAssertFalse(primary.isEmpty)
        XCTAssertFalse(secondary.isEmpty)
        XCTAssertFalse(auxiliary.isEmpty)
        XCTAssertLessThanOrEqual(header.count, 3)
        XCTAssertLessThanOrEqual(primary.count, 1)
        XCTAssertLessThanOrEqual(secondary.count, 4)
        XCTAssertLessThanOrEqual(auxiliary.count, 4)
    }

    // The guide caps generic passes with a square barcode (QR) at 4 secondary and auxiliary fields combined.
    func testSquareBarcodeCombinedFieldLimit() throws {
        var pass = PassObject()
        pass.barcodeType = .qr
        pass.barcodeString = "member-123"
        pass.secondaryFieldOneLabel = "Name"
        pass.secondaryFieldOneText = "Ada Lovelace"
        pass.isSecondaryFieldTwoOn = true
        pass.secondaryFieldTwoLabel = "Since"
        pass.secondaryFieldTwoText = "2020"
        pass.auxiliaryFieldOneLabel = "Store"
        pass.auxiliaryFieldOneText = "Main Street"
        pass.isAuxiliaryFieldTwoOn = true
        pass.auxiliaryFieldTwoLabel = "Aisle"
        pass.auxiliaryFieldTwoText = "4"

        let (json, _) = try generatePackage(from: pass)

        let combined = styleFields(json, "secondaryFields").count + styleFields(json, "auxiliaryFields").count
        XCTAssertLessThanOrEqual(combined, 4)
    }

    func testCode128BarcodeStructure() throws {
        var pass = PassObject()
        pass.barcodeType = .code128
        pass.barcodeString = "CODE128DATA"
        pass.altText = "1234"

        let (json, _) = try generatePackage(from: pass)

        let barcode = try XCTUnwrap(json["barcode"] as? [String: Any])
        XCTAssertEqual(barcode["message"] as? String, "CODE128DATA")
        XCTAssertEqual(barcode["format"] as? String, "PKBarcodeFormatCode128")
        XCTAssertEqual(barcode["messageEncoding"] as? String, "iso-8859-1")
        XCTAssertEqual(barcode["altText"] as? String, "1234")
    }

    func testPDF417BarcodeStructure() throws {
        var pass = PassObject()
        pass.barcodeType = .pdf417
        pass.barcodeString = "PDF417DATA"

        let (json, _) = try generatePackage(from: pass)

        let barcode = try XCTUnwrap(json["barcode"] as? [String: Any])
        XCTAssertEqual(barcode["message"] as? String, "PDF417DATA")
        XCTAssertEqual(barcode["format"] as? String, "PKBarcodeFormatPDF417")
        XCTAssertEqual(barcode["messageEncoding"] as? String, "iso-8859-1")
        XCTAssertNil(barcode["altText"])
    }

    func testQRBarcodeStructure() throws {
        var pass = PassObject()
        pass.barcodeType = .qr
        pass.barcodeString = "https://example.com/member/123"

        let (json, _) = try generatePackage(from: pass)

        let barcode = try XCTUnwrap(json["barcode"] as? [String: Any])
        XCTAssertEqual(barcode["message"] as? String, "https://example.com/member/123")
        XCTAssertEqual(barcode["format"] as? String, "PKBarcodeFormatQR")
        XCTAssertEqual(barcode["messageEncoding"] as? String, "us-ascii")
    }

    // The guide recommends ISO 8859-1 where possible
    // when the barcode text can't be encoded with the chosen encoding
    // the generator must fall back to a compatible one rather than emitting an unencodable message.
    func testQRBarcodeFallsBackToCompatibleEncoding() throws {
        var pass = PassObject()
        pass.barcodeType = .qr
        pass.barcodeString = "café"

        let (json, _) = try generatePackage(from: pass)

        let barcode = try XCTUnwrap(json["barcode"] as? [String: Any])
        XCTAssertEqual(barcode["messageEncoding"] as? String, "utf-8")
    }

    // Barcode types PassKit cannot display natively are rendered as images
    // so they must not also appear as a pass barcode.
    func testBarcodeOmittedForNonPassKitBarcodeType() throws {
        var pass = PassObject()
        pass.barcodeType = .ean13
        pass.barcodeString = "1234567890123"

        let (json, _) = try generatePackage(from: pass)

        XCTAssertNil(json["barcode"])
    }

    func testBarcodeOmittedWhenBarcodeStringIsEmpty() throws {
        var pass = PassObject()
        pass.barcodeType = .qr
        pass.barcodeString = ""

        let (json, _) = try generatePackage(from: pass)

        XCTAssertNil(json["barcode"])
    }

    // The guide specifies colors as R/G/B values
    func testColorsUseRGBFormat() throws {
        var pass = PassObject()
        pass.foregroundColor = 0xFF8000
        pass.backgroundColor = 0x0000FF
        pass.labelColor = 0x00FF00

        let (json, _) = try generatePackage(from: pass)

        XCTAssertEqual(json["foregroundColor"] as? String, "rgb(255, 128, 0)")
        XCTAssertEqual(json["backgroundColor"] as? String, "rgb(0, 0, 255)")
        XCTAssertEqual(json["labelColor"] as? String, "rgb(0, 255, 0)")
        assertRGBColor(json["foregroundColor"])
        assertRGBColor(json["backgroundColor"])
        assertRGBColor(json["labelColor"])
    }

    // Dates use the W3C timestamp format
    func testExpirationDateUsesISO8601Format() throws {
        var pass = PassObject()
        pass.hasExpirationDate = true
        pass.expirationDate = Date(timeIntervalSince1970: 1_800_000_000)

        let (json, _) = try generatePackage(from: pass)

        let string = try XCTUnwrap(json["expirationDate"] as? String)
        XCTAssertTrue(string.contains("T"))
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        XCTAssertEqual(formatter.date(from: string), pass.expirationDate)
    }

    func testExpirationDateOmittedWhenDisabled() throws {
        let pass = PassObject()

        let (json, _) = try generatePackage(from: pass)

        XCTAssertNil(json["expirationDate"])
    }

    // The guide allows up to ten relevant locations
    // each one is a dictionary with latitude and longitude and an optional relevantText.
    func testLocationsStructureAtMaximumCount() throws {
        var pass = PassObject()
        pass.locations = (0 ..< 10).map { index in
            PassLocation(
                latitude: 37.331 + Double(index) * 0.001,
                longitude: -122.029,
                relevantText: index == 0 ? "Store nearby" : ""
            )
        }

        let (json, _) = try generatePackage(from: pass)

        let locations = try XCTUnwrap(json["locations"] as? [[String: Any]])
        XCTAssertEqual(locations.count, 10)
        for location in locations {
            let latitude = try XCTUnwrap((location["latitude"] as? NSNumber)?.doubleValue)
            let longitude = try XCTUnwrap((location["longitude"] as? NSNumber)?.doubleValue)
            XCTAssertTrue((-90.0 ... 90.0).contains(latitude))
            XCTAssertTrue((-180.0 ... 180.0).contains(longitude))
        }
        XCTAssertEqual(locations.first?["relevantText"] as? String, "Store nearby")
        XCTAssertNil(locations.last?["relevantText"])
    }

    func testLocationsOmittedWhenEmpty() throws {
        let pass = PassObject()

        let (json, _) = try generatePackage(from: pass)

        XCTAssertNil(json["locations"])
    }

    // The guide compresses the contents of the pass package, so every
    // entry sits at the root of the zip, and the only files are pass.json
    // and the images PassKit supports.
    func testPackageEntriesAreAtZipRootAndAllowed() throws {
        var pass = PassObject()
        pass.passIcon = pngData(width: 300, height: 300)
        pass.logoImage = pngData(width: 800, height: 200)
        pass.thumbnailImage = pngData(width: 300, height: 300)

        let (_, files) = try generatePackage(from: pass)

        let imageBases = ["icon", "logo", "thumbnail", "strip", "background", "footer"]
        for name in files.keys {
            XCTAssertFalse(name.contains("/"), "Entry \(name) is not at the package root")
            guard name != "pass.json" else { continue }
            XCTAssertTrue(name.hasSuffix(".png"), "Unexpected file in package: \(name)")
            var base = String(name.dropLast(4))
            for suffix in ["@2x", "@3x"] where base.hasSuffix(suffix) {
                base = String(base.dropLast(3))
            }
            XCTAssertTrue(imageBases.contains(base), "Unexpected file in package: \(name)")
        }
    }

    func testIconIsAlwaysIncluded() throws {
        var pass = PassObject()
        pass.passIcon = pngData(width: 300, height: 300)

        let (_, files) = try generatePackage(from: pass)

        XCTAssertNotNil(files["icon.png"])
    }

    func testImagesAreValidPNGData() throws {
        var pass = PassObject()
        pass.passIcon = pngData(width: 300, height: 300)
        pass.logoImage = pngData(width: 800, height: 200)
        pass.thumbnailImage = pngData(width: 300, height: 300)

        let (_, files) = try generatePackage(from: pass)

        let pngMagic: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        for (name, data) in files where name != "pass.json" {
            XCTAssertTrue(data.starts(with: pngMagic), "\(name) is not PNG data")
        }
    }

    // Images are scaled to fill their allotted space from the guide
    // (logo 160x50 points, thumbnail 90x90 points)
    // so no variant may exceed three times the allotted points.
    // The icon uses the app's PassKitConstants.
    func testImageVariantsStayWithinAllottedSizes() throws {
        var pass = PassObject()
        pass.passIcon = pngData(width: 300, height: 300)
        pass.logoImage = pngData(width: 800, height: 200)
        pass.thumbnailImage = pngData(width: 300, height: 300)

        let (_, files) = try generatePackage(from: pass)

        let limits: [String: (width: Int, height: Int)] = [
            "icon": (Int(PassKitConstants.IconImage.width) * 3, Int(PassKitConstants.IconImage.height) * 3),
            "logo": (160 * 3, 50 * 3),
            "thumbnail": (90 * 3, 90 * 3),
        ]
        for (name, data) in files where name != "pass.json" {
            var base = String(name.dropLast(4))
            for suffix in ["@2x", "@3x"] where base.hasSuffix(suffix) {
                base = String(base.dropLast(3))
            }
            guard let limit = limits[base], let size = pixelSize(of: data) else { continue }
            XCTAssertLessThanOrEqual(size.width, limit.width, "\(name) is wider than its allotted space")
            XCTAssertLessThanOrEqual(size.height, limit.height, "\(name) is taller than its allotted space")
        }
    }

    // Runs generatePass and returns the parsed pass.json plus every file in
    // the package, keyed by entry name.
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

    private func fullyPopulatedPass() -> PassObject {
        var pass = PassObject()
        pass.primaryFieldLabel = "Member"
        pass.primaryFieldText = "Ada"
        pass.headerFieldOneLabel = "Points"
        pass.headerFieldOneText = "10"
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
        return pass
    }

    private func styleKey(in json: [String: Any]) -> String? {
        styleKeys.first { json[$0] != nil }
    }

    private func styleFields(_ json: [String: Any], _ key: String) -> [[String: Any]] {
        guard let styleName = styleKey(in: json),
              let style = json[styleName] as? [String: Any]
        else { return [] }
        return style[key] as? [[String: Any]] ?? []
    }

    private func allFields(in json: [String: Any]) -> [[String: Any]] {
        ["headerFields", "primaryFields", "secondaryFields", "auxiliaryFields", "backFields"]
            .flatMap { styleFields(json, $0) }
    }

    private func pngData(width: Int, height: Int) -> Data {
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return image.pngData() ?? Data()
    }

    private func pixelSize(of data: Data) -> (width: Int, height: Int)? {
        guard let cgImage = UIImage(data: data)?.cgImage else { return nil }
        return (cgImage.width, cgImage.height)
    }

    private func assertRGBColor(_ value: Any?, file: StaticString = #filePath, line: UInt = #line) {
        let string = value as? String ?? ""
        XCTAssertTrue(string.hasPrefix("rgb("), "Color '\(string)' is not in rgb(r, g, b) format", file: file, line: line)
        XCTAssertTrue(string.hasSuffix(")"), "Color '\(string)' is not in rgb(r, g, b) format", file: file, line: line)
        let components = string
            .replacingOccurrences(of: "rgb(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        XCTAssertEqual(components.count, 3, "Color '\(string)' does not have three components", file: file, line: line)
        for component in components {
            let number = Int(component) ?? -1
            XCTAssertTrue((0 ... 255).contains(number), "Color component '\(component)' is not in 0...255", file: file, line: line)
        }
    }
}
