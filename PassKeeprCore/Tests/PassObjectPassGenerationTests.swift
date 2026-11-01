@testable import PassKeeprCore
import XCTest

// Tests for the pass generation decisions that live on `PassObject` itself (see PassObject+PassGeneration.swift),
// independent of the zipped package produced by `generatePass`.
final class PassObjectPassGenerationTests: XCTestCase {
    private let nativeBarcodeTypes: [BarcodeType] = [.code128, .pdf417, .qr, .none]
    private let stripBarcodeTypes: [BarcodeType] = [.code39, .code93, .upce, .upca, .ean13]

    private let image = TestImages.redPNG(width: 100, height: 100)

    // A barcode string that is valid for EAN-13
    private let validEAN13 = "1234567890123"

    // MARK: - Barcode type predicates

    func testNativeBarcodeTypesAreNative() {
        for type in nativeBarcodeTypes {
            var pass = PassObject()
            pass.barcodeType = type
            XCTAssertTrue(pass.isNativeBarcodeType, "\(type) should be native")
        }
    }

    func testStripBarcodeTypesAreNotNative() {
        for type in stripBarcodeTypes {
            var pass = PassObject()
            pass.barcodeType = type
            XCTAssertFalse(pass.isNativeBarcodeType, "\(type) should not be native")
        }
    }

    func testEveryBarcodeTypeIsClassified() {
        XCTAssertEqual(Set(nativeBarcodeTypes + stripBarcodeTypes).count, BarcodeType.allCases.count)
    }

    func testNativeClassificationMatchesStripImageUsage() {
        for type in BarcodeType.allCases {
            var pass = PassObject()
            pass.barcodeType = type
            XCTAssertEqual(pass.isNativeBarcodeType, !type.doesBarcodeUseStripImage(), "\(type)")
        }
    }

    func testBackgroundImageSupportFollowsNativeBarcodeType() {
        for type in BarcodeType.allCases {
            var pass = PassObject()
            pass.barcodeType = type
            XCTAssertEqual(pass.isBackgroundImageSupported, pass.isNativeBarcodeType, "\(type)")
        }
    }

    // MARK: - Background image

    func testHasBackgroundImageRequiresImageAndFlag() {
        var pass = PassObject()
        XCTAssertFalse(pass.hasBackgroundImage)

        // Setting the image turns the flag on
        pass.backgroundImage = image
        XCTAssertTrue(pass.hasBackgroundImage)

        pass.isBackgroundImageOn = false
        XCTAssertFalse(pass.hasBackgroundImage)

        pass.backgroundImage = Data()
        pass.isBackgroundImageOn = true
        XCTAssertFalse(pass.hasBackgroundImage)
    }

    func testBackgroundImageIncludedForNativeBarcodeTypes() {
        for type in nativeBarcodeTypes {
            var pass = PassObject()
            pass.barcodeType = type
            pass.backgroundImage = image
            XCTAssertTrue(pass.shouldIncludeBackgroundImage, "\(type)")
        }
    }

    // A background flag left on while the barcode is rendered as a strip image
    // is still "had" by the pass, but must not end up in the package.
    func testBackgroundImageExcludedForStripBarcodeTypes() {
        for type in stripBarcodeTypes {
            var pass = PassObject()
            pass.barcodeType = type
            pass.backgroundImage = image
            XCTAssertTrue(pass.hasBackgroundImage, "\(type)")
            XCTAssertFalse(pass.shouldIncludeBackgroundImage, "\(type)")
        }
    }

    func testBackgroundImageExcludedWhenFlagIsOff() {
        var pass = PassObject()
        pass.backgroundImage = image
        pass.isBackgroundImageOn = false
        XCTAssertFalse(pass.shouldIncludeBackgroundImage)
    }

    // MARK: - Strip image

    func testNoStripImageDataMeansNoStripImage() {
        var pass = PassObject()
        pass.barcodeType = .ean13
        pass.barcodeString = validEAN13
        XCTAssertFalse(pass.shouldAddStripImage)

        pass.isCustomStripImageOn = true
        XCTAssertFalse(pass.shouldAddStripImage)
        XCTAssertFalse(pass.shouldIncludeStripImage)
    }

    func testStripBarcodeWithValidValueAddsStripImage() {
        for (type, value) in [(BarcodeType.ean13, validEAN13), (.upca, "123456789012"), (.upce, "123456"), (.code39, "ABC-123"), (.code93, "ABC-123")] {
            var pass = PassObject()
            pass.barcodeType = type
            pass.barcodeString = value
            pass.stripImage = image
            XCTAssertTrue(pass.shouldAddStripImage, "\(type)")
            XCTAssertTrue(pass.shouldIncludeStripImage, "\(type)")
        }
    }

    func testStripBarcodeWithInvalidValueDoesNotAddStripImage() {
        var pass = PassObject()
        pass.barcodeType = .ean13
        pass.barcodeString = "not a number"
        pass.stripImage = image
        XCTAssertFalse(pass.shouldAddStripImage)

        pass.barcodeString = ""
        XCTAssertFalse(pass.shouldAddStripImage)
    }

    func testNativeBarcodeStripImageIgnoredUnlessCustom() {
        for type in nativeBarcodeTypes {
            var pass = PassObject()
            pass.barcodeType = type
            pass.barcodeString = "123456789012"
            pass.stripImage = image
            XCTAssertFalse(pass.shouldAddStripImage, "\(type)")

            pass.isCustomStripImageOn = true
            XCTAssertTrue(pass.shouldAddStripImage, "\(type)")
            XCTAssertTrue(pass.shouldIncludeStripImage, "\(type)")
        }
    }

    func testHasStripBarcodeImageRequiresStripTypeValidValueAndData() {
        for (type, value) in [(BarcodeType.ean13, validEAN13), (.upca, "123456789012"), (.upce, "123456"), (.code39, "ABC-123"), (.code93, "ABC-123")] {
            var pass = PassObject()
            pass.barcodeType = type
            pass.barcodeString = value
            XCTAssertFalse(pass.hasStripBarcodeImage, "\(type) without strip data")

            pass.stripImage = image
            XCTAssertTrue(pass.hasStripBarcodeImage, "\(type)")

            pass.barcodeString = "bad!#"
            XCTAssertFalse(pass.hasStripBarcodeImage, "\(type) with invalid value")
        }
    }

    func testHasStripBarcodeImageIgnoresCustomStripImage() {
        var pass = PassObject()
        pass.barcodeType = .ean13
        pass.barcodeString = "bad"
        pass.stripImage = image
        pass.isCustomStripImageOn = true
        XCTAssertFalse(pass.hasStripBarcodeImage)

        for type in nativeBarcodeTypes {
            pass.barcodeType = type
            pass.barcodeString = "123456789012"
            XCTAssertFalse(pass.hasStripBarcodeImage, "\(type)")
        }
    }

    // A custom strip image set on a native barcode type that is later switched to a strip barcode type
    // still counts as a strip image, even though the barcode value is invalid.
    func testCustomStripImageAppliesEvenWithInvalidStripBarcode() {
        var pass = PassObject()
        pass.barcodeType = .ean13
        pass.barcodeString = "bad"
        pass.stripImage = image
        pass.isCustomStripImageOn = true
        XCTAssertTrue(pass.shouldAddStripImage)
    }

    // A background image wins over a strip image: the strip is "added" in the sense that
    // the pass has one, but it is dropped from the package.
    func testBackgroundImageWinsOverCustomStripImage() {
        var pass = PassObject()
        pass.barcodeType = .qr
        pass.isCustomStripImageOn = true
        pass.stripImage = image
        pass.backgroundImage = image

        XCTAssertTrue(pass.shouldAddStripImage)
        XCTAssertTrue(pass.shouldIncludeBackgroundImage)
        XCTAssertFalse(pass.shouldIncludeStripImage)
    }

    // MARK: - Pass style

    func testDefaultStyleIsGeneric() {
        XCTAssertEqual(PassObject().passStyleKey, "generic")
    }

    func testCouponStyle() {
        var pass = PassObject()
        pass.isCoupon = true
        XCTAssertEqual(pass.passStyleKey, "coupon")

        // Coupons can have strip images and remain coupons
        pass.barcodeType = .ean13
        pass.barcodeString = validEAN13
        pass.stripImage = image
        XCTAssertEqual(pass.passStyleKey, "coupon")
    }

    func testStripBarcodeSelectsStoreCard() {
        var pass = PassObject()
        pass.barcodeType = .ean13
        pass.barcodeString = validEAN13
        pass.stripImage = image
        XCTAssertEqual(pass.passStyleKey, "storeCard")
    }

    func testCustomStripImageSelectsStoreCard() {
        var pass = PassObject()
        pass.barcodeType = .qr
        pass.isCustomStripImageOn = true
        pass.stripImage = image
        XCTAssertEqual(pass.passStyleKey, "storeCard")
    }

    func testStripBarcodeWithInvalidValueStaysGeneric() {
        var pass = PassObject()
        pass.barcodeType = .ean13
        pass.barcodeString = "bad"
        pass.stripImage = image
        XCTAssertEqual(pass.passStyleKey, "generic")
    }

    func testBackgroundImageSelectsEventTicketOverCoupon() {
        var pass = PassObject()
        pass.isCoupon = true
        pass.backgroundImage = image
        XCTAssertEqual(pass.passStyleKey, "eventTicket")
    }

    // The style must never claim a background image the package won't contain.
    func testUnsupportedBackgroundImageDoesNotSelectEventTicket() {
        var pass = PassObject()
        pass.barcodeType = .ean13
        pass.barcodeString = validEAN13
        pass.stripImage = image
        pass.backgroundImage = image

        XCTAssertEqual(pass.passStyleKey, "storeCard")
        XCTAssertTrue(pass.shouldIncludeStripImage)
        XCTAssertFalse(pass.shouldIncludeBackgroundImage)
    }

    func testStyleMatchesPackagedImages() {
        var pass = PassObject()
        for type in BarcodeType.allCases {
            for coupon in [false, true] {
                for custom in [false, true] {
                    for background in [false, true] {
                        pass.barcodeType = type
                        pass.barcodeString = "123456789012"
                        pass.isCoupon = coupon
                        pass.isCustomStripImageOn = custom
                        pass.stripImage = image
                        pass.backgroundImage = background ? image : Data()

                        // A package never contains both
                        XCTAssertFalse(pass.shouldIncludeStripImage && pass.shouldIncludeBackgroundImage)
                        if pass.shouldIncludeBackgroundImage {
                            XCTAssertEqual(pass.passStyleKey, "eventTicket")
                        }
                        if pass.passStyleKey == "eventTicket" {
                            XCTAssertTrue(pass.shouldIncludeBackgroundImage)
                        }
                        if pass.passStyleKey == "storeCard" {
                            XCTAssertTrue(pass.shouldIncludeStripImage)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Field content predicates

    func testFieldContentPredicates() {
        var pass = PassObject()
        XCTAssertFalse(pass.hasHeaderFieldOneContent)
        XCTAssertFalse(pass.hasSecondaryFieldOneContent)
        XCTAssertFalse(pass.hasAuxiliaryFieldOneContent)

        pass.headerFieldOneLabel = "Label"
        pass.secondaryFieldOneText = "Text"
        pass.auxiliaryFieldOneLabel = "Label"
        XCTAssertTrue(pass.hasHeaderFieldOneContent)
        XCTAssertTrue(pass.hasSecondaryFieldOneContent)
        XCTAssertTrue(pass.hasAuxiliaryFieldOneContent)

        pass.headerFieldOneLabel = ""
        pass.headerFieldOneText = "Text"
        XCTAssertTrue(pass.hasHeaderFieldOneContent)
    }

    // MARK: - pass.json contents

    func testPassJSONDictionaryHasExactlyOneStyleKey() throws {
        let json = PassObject().passJSONDictionary
        let styles = ["boardingPass", "coupon", "eventTicket", "generic", "storeCard"].filter { json[$0] != nil }
        XCTAssertEqual(styles, ["generic"])
    }

    func testPassJSONDictionaryUsesPassStyleKey() throws {
        var pass = PassObject()
        pass.barcodeType = .ean13
        pass.barcodeString = validEAN13
        pass.stripImage = image
        pass.secondaryFieldOneLabel = "Name"
        pass.secondaryFieldOneText = "Ada"

        let json = pass.passJSONDictionary
        let style = try XCTUnwrap(json[pass.passStyleKey] as? [String: Any])
        XCTAssertEqual(pass.passStyleKey, "storeCard")
        XCTAssertNotNil(style["secondaryFields"])
    }

    func testPassJSONDictionaryOmitsSigningNonce() {
        // The nonce is added by generatePass so every generated package gets a fresh one
        XCTAssertNil(PassObject().passJSONDictionary["userInfo"])
    }

    func testPrimaryFieldIncludedWithoutStripImage() throws {
        var pass = PassObject()
        pass.primaryFieldLabel = "Name"
        pass.primaryFieldText = "Ada"

        let primary = try primaryFields(of: pass)
        XCTAssertEqual(primary.count, 1)
        XCTAssertEqual(primary.first?["value"] as? String, "Ada")
    }

    func testPrimaryFieldOmittedWithStripBarcode() throws {
        var pass = PassObject()
        pass.barcodeType = .ean13
        pass.barcodeString = validEAN13
        pass.stripImage = image
        pass.primaryFieldText = "Ada"

        XCTAssertTrue(try primaryFields(of: pass).isEmpty)
    }

    func testPrimaryFieldOmittedWithCustomStripImage() throws {
        var pass = PassObject()
        pass.isCustomStripImageOn = true
        pass.primaryFieldText = "Ada"

        XCTAssertTrue(try primaryFields(of: pass).isEmpty)
    }

    // The strip is dropped when a background wins, but a custom strip image still suppresses the primary field
    func testPrimaryFieldOmittedWhenCustomStripImageLosesToBackground() throws {
        var pass = PassObject()
        pass.barcodeType = .qr
        pass.isCustomStripImageOn = true
        pass.stripImage = image
        pass.backgroundImage = image
        pass.primaryFieldText = "Ada"

        XCTAssertFalse(pass.shouldIncludeStripImage)
        XCTAssertTrue(try primaryFields(of: pass).isEmpty)
    }

    func testHeaderFieldOneIncludedWithOnlyLabelOrOnlyText() throws {
        var labelOnly = PassObject()
        labelOnly.headerFieldOneLabel = "Label"
        var textOnly = PassObject()
        textOnly.headerFieldOneText = "Text"

        for pass in [labelOnly, textOnly] {
            let style = try XCTUnwrap(pass.passJSONDictionary[pass.passStyleKey] as? [String: Any])
            let headers = try XCTUnwrap(style["headerFields"] as? [[String: Any]])
            XCTAssertEqual(headers.first?["key"] as? String, "header1")
        }
    }

    func testAuxiliaryFieldsOmittedWithCustomStripImage() {
        var pass = PassObject()
        pass.isCustomStripImageOn = true
        pass.auxiliaryFieldOneLabel = "Label"
        pass.auxiliaryFieldOneText = "Text"

        let style = pass.passJSONDictionary[pass.passStyleKey] as? [String: Any]
        XCTAssertNil(style?["auxiliaryFields"])
    }

    func testAuxiliaryFieldsIncludedWithoutCustomStripImage() throws {
        var pass = PassObject()
        pass.auxiliaryFieldOneLabel = "Label"
        pass.auxiliaryFieldOneText = "Text"

        let style = try XCTUnwrap(pass.passJSONDictionary[pass.passStyleKey] as? [String: Any])
        let fields = try XCTUnwrap(style["auxiliaryFields"] as? [[String: Any]])
        XCTAssertEqual(fields.first?["key"] as? String, "auxiliary1")
    }

    func testEmptyFieldsAreOmitted() {
        let style = PassObject().passJSONDictionary["generic"] as? [String: Any]
        XCTAssertNil(style?["headerFields"])
        XCTAssertNil(style?["secondaryFields"])
        XCTAssertNil(style?["auxiliaryFields"])
    }

    // MARK: - Barcode dictionary

    func testBarcodeDictionaryNilForNonNativeOrEmpty() {
        var pass = PassObject()
        XCTAssertNil(pass.barcodeDictionary)

        pass.barcodeType = .qr
        XCTAssertNil(pass.barcodeDictionary)

        pass.barcodeType = .ean13
        pass.barcodeString = validEAN13
        XCTAssertNil(pass.barcodeDictionary)
    }

    func testBarcodeDictionaryPresentForNativeTypes() {
        for (type, format) in [(BarcodeType.code128, "PKBarcodeFormatCode128"), (.pdf417, "PKBarcodeFormatPDF417"), (.qr, "PKBarcodeFormatQR")] {
            var pass = PassObject()
            pass.barcodeType = type
            pass.barcodeString = "DATA"
            XCTAssertEqual(pass.barcodeDictionary?["format"] as? String, format, "\(type)")
            XCTAssertNotNil(pass.passJSONDictionary["barcode"], "\(type)")
        }
    }

    // MARK: - passFieldDict

    func testPassFieldDictPlainValue() {
        let field = passFieldDict(key: "k", label: "L", text: "T", isCurrency: false, currencyCode: "USD")
        XCTAssertEqual(field["key"] as? String, "k")
        XCTAssertEqual(field["label"] as? String, "L")
        XCTAssertEqual(field["value"] as? String, "T")
        XCTAssertNil(field["currencyCode"])
    }

    func testPassFieldDictBlankIfEmpty() {
        let blank = passFieldDict(key: "k", label: "L", text: "", isCurrency: false, currencyCode: "USD", blankIfEmpty: true)
        XCTAssertEqual(blank["value"] as? String, " ")

        let empty = passFieldDict(key: "k", label: "L", text: "", isCurrency: false, currencyCode: "USD")
        XCTAssertEqual(empty["value"] as? String, "")
    }

    func testPassFieldDictCurrency() {
        let field = passFieldDict(key: "k", label: "L", text: "5", isCurrency: true, currencyCode: "EUR")
        XCTAssertEqual(field["currencyCode"] as? String, "EUR")
        XCTAssertEqual((field["value"] as? NSNumber)?.doubleValue, 5)
    }

    // MARK: - Helpers

    private func primaryFields(of pass: PassObject) throws -> [[String: Any]] {
        let style = try XCTUnwrap(pass.passJSONDictionary[pass.passStyleKey] as? [String: Any])
        return style["primaryFields"] as? [[String: Any]] ?? []
    }
}
