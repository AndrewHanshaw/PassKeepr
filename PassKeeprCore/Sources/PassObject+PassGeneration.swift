import Foundation

// Fields required by every PassKit pass
// These are not customizable by the user, so they're kept separate from the PassObject used to otherwise build the pass
let requiredFields: [String: Any] = [
    "formatVersion": 1,
    "teamIdentifier": "NZDS56Z4Q9",
    "organizationName": "PassKeepr",
]

// Pass generation decisions that depend only on the pass's own data
// (which pass style it is and which images belong in the generated pass).
// GeneratePass uses these to create the pass,
// and keeping them on the model means the decisions live with the data they are derived from.
extension PassObject {
    // Whether a background image can be shown for this pass's barcode type
    public var isBackgroundImageSupported: Bool {
        if (barcodeType == BarcodeType.code128) || (barcodeType == BarcodeType.pdf417) || (barcodeType == BarcodeType.qr) || (barcodeType == BarcodeType.none) {
            return true
        } else {
            return false
        }
    }

    // Whether the background image belongs in the generated package
    public var shouldIncludeBackgroundImage: Bool {
        if (isBackgroundImageOn && backgroundImage != Data()) && isBackgroundImageSupported {
            return true
        } else {
            return false
        }
    }

    // Whether there is a rendered strip barcode to show: a barcode type the app renders as an image,
    // a valid barcode value, and the generated strip data.
    // Unlike shouldAddStripImage, this does not consider the user's custom strip image.
    public var hasStripBarcodeImage: Bool {
        barcodeType.doesBarcodeUseStripImage()
            && barcodeType.isEnteredBarcodeValueValid(string: barcodeString)
            && stripImage != Data()
    }

    // Whether a strip image applies to this pass, before the background image is taken into account:
    // either a rendered strip barcode, or the user's custom strip image.
    public var shouldAddStripImage: Bool {
        hasStripBarcodeImage || (isCustomStripImageOn && stripImage != Data())
    }

    // Whether the strip image belongs in the generated package.
    // A background image wins over a strip image.
    // The two cannot coexist on one pass, the strip is the one dropped if both are defined.
    var shouldIncludeStripImage: Bool {
        shouldAddStripImage && !shouldIncludeBackgroundImage
    }

    // The pass style key for pass.json, chosen from the images the package will actually contain
    // so the style never claims an image that is not included
    var passStyleKey: String {
        if shouldIncludeBackgroundImage {
            return "eventTicket"
        } else if isCoupon { // Coupon passes can have strip images, that toggle is the next-highest priority
            return "coupon"
        } else if shouldIncludeStripImage { // non-coupon passes with strip images
            return "storeCard"
        } else {
            // Default to generic
            return "generic"
        }
    }

    // The complete dictionary written to pass.json when this pass is generated
    var passJSONDictionary: [String: Any] {
        // Add the required data to the pass
        var passData: [String: Any] = requiredFields
        passData["passTypeIdentifier"] = "pass.com.hanshaw.passKeepr.\(group)"
        passData.merge(["description": description]) { _, _ in }
        passData.merge(["serialNumber": id.uuidString]) { _, _ in }
        passData.merge(["foregroundColor": foregroundColor.toRGBString()]) { _, _ in }
        passData.merge(["backgroundColor": backgroundColor.toRGBString()]) { _, _ in }
        passData.merge(["labelColor": labelColor.toRGBString()]) { _, _ in }
        if hasExpirationDate {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            passData.merge(["expirationDate": formatter.string(from: expirationDate)]) { _, _ in }
        }
        if !locations.isEmpty {
            // PassKit allows at most ten relevant locations per pass
            let encoded: [[String: Any]] = locations.prefix(10).map { loc in
                var d: [String: Any] = ["latitude": loc.latitude, "longitude": loc.longitude]
                if !loc.relevantText.isEmpty {
                    d["relevantText"] = loc.relevantText
                }
                return d
            }
            passData.merge(["locations": encoded]) { _, _ in }
        }
        if !associatedStoreIdentifiers.isEmpty {
            passData.merge(["associatedStoreIdentifiers": associatedStoreIdentifiers]) { _, _ in }
        }

        // Add customizable data to the pass
        var data: [String: Any] = [:]

        // A primary field with a strip image *is* strictly allowed by PassKit, however it looks horrible, so I'm just disabling it for now to avoid having to even think about it
        if !shouldIncludeStripImage && !isCustomStripImageOn {
            let primaryFields: [String: Any] = passFieldDict(
                key: "primary",
                label: primaryFieldLabel,
                text: primaryFieldText,
                isCurrency: isCurrencyFieldsOn && isPrimaryFieldCurrency,
                currencyCode: currencyCode
            )

            data.merge(["primaryFields": [primaryFields]]) { _, _ in }
        }

        if headerFieldOneLabel != "" || headerFieldOneText != "" || isHeaderFieldTwoOn {
            data.merge(encodedHeaderFields) { _, _ in }
        }

        if secondaryFieldOneLabel != "" || secondaryFieldOneText != "" || isSecondaryFieldTwoOn || isSecondaryFieldThreeOn {
            data.merge(encodedSecondaryFields) { _, _ in }
        }

        if !isCustomStripImageOn, auxiliaryFieldOneLabel != "" || auxiliaryFieldOneText != "" || isAuxiliaryFieldTwoOn || isAuxiliaryFieldThreeOn {
            data.merge(encodedAuxiliaryFields) { _, _ in }
        }

        var passStyle: [String: Any] = [passStyleKey: data]

        if let barcodeDictionary {
            passStyle.merge(["barcode": barcodeDictionary]) { _, _ in }
        }

        passData.merge(passStyle) { _, _ in }

        return passData
    }

    // The PassKit barcode dictionary for pass.json, or nil when this pass has no natively displayable barcode
    var barcodeDictionary: [String: Any]? {
        guard barcodeType == BarcodeType.code128 || barcodeType == BarcodeType.pdf417 || barcodeType == BarcodeType.qr, barcodeString != "" else {
            return nil
        }

        var barcodeFields: [String: Any] = [:]

        if barcodeType == BarcodeType.code128 {
            barcodeFields = [
                "message": barcodeString,
                "format": "PKBarcodeFormatCode128",
                "messageEncoding": "iso-8859-1",
            ]
        } else if barcodeType == BarcodeType.pdf417 {
            barcodeFields = [
                "message": barcodeString,
                "format": "PKBarcodeFormatPDF417",
                "messageEncoding": "iso-8859-1",
            ]
        } else if barcodeType == BarcodeType.qr {
            let safeEncoding = qrCodeEncoding.isCompatible(with: barcodeString)
                ? qrCodeEncoding
                : QrCodeEncoding.minimumEncoding(for: barcodeString)
            barcodeFields = [
                "message": barcodeString,
                "format": "PKBarcodeFormatQR",
                "messageEncoding": safeEncoding.ianaEncodingName,
            ]
        }

        if altText != "" {
            barcodeFields.merge(["altText": altText]) { _, _ in }
        }

        return barcodeFields
    }

    var encodedHeaderFields: [String: Any] {
        var encodedData: [Any] = []

        if headerFieldOneLabel != "" || headerFieldOneText != "" {
            let headerField1 = passFieldDict(
                key: "header1",
                label: headerFieldOneLabel,
                text: headerFieldOneText,
                isCurrency: isCurrencyFieldsOn && isHeaderFieldOneCurrency,
                currencyCode: currencyCode
            )

            encodedData.append(headerField1)
        }

        if isHeaderFieldTwoOn {
            let headerField2 = passFieldDict(
                key: "header2",
                label: headerFieldTwoLabel,
                text: headerFieldTwoText,
                isCurrency: isCurrencyFieldsOn && isHeaderFieldTwoCurrency,
                currencyCode: currencyCode
            )

            encodedData.append(headerField2)
        }

        return [
            "headerFields": encodedData,
        ]
    }

    var encodedSecondaryFields: [String: Any] {
        var encodedData: [Any] = []

        let hasFieldThree = isSecondaryFieldThreeOn
        let hasFieldTwo = isSecondaryFieldTwoOn || hasFieldThree
        let hasFieldOne = secondaryFieldOneLabel != "" || secondaryFieldOneText != "" || hasFieldTwo

        if hasFieldOne {
            let secondaryField1 = passFieldDict(
                key: "secondary1",
                label: secondaryFieldOneLabel,
                text: secondaryFieldOneText,
                isCurrency: isCurrencyFieldsOn && isSecondaryFieldOneCurrency,
                currencyCode: currencyCode,
                blankIfEmpty: true
            )

            encodedData.append(secondaryField1)
        }

        if hasFieldTwo {
            let secondaryField2 = passFieldDict(
                key: "secondary2",
                label: secondaryFieldTwoLabel,
                text: secondaryFieldTwoText,
                isCurrency: isCurrencyFieldsOn && isSecondaryFieldTwoCurrency,
                currencyCode: currencyCode,
                blankIfEmpty: true
            )

            encodedData.append(secondaryField2)
        }

        if hasFieldThree {
            let secondaryField3 = passFieldDict(
                key: "secondary3",
                label: secondaryFieldThreeLabel,
                text: secondaryFieldThreeText,
                isCurrency: isCurrencyFieldsOn && isSecondaryFieldThreeCurrency,
                currencyCode: currencyCode,
                blankIfEmpty: true
            )

            encodedData.append(secondaryField3)
        }

        return [
            "secondaryFields": encodedData,
        ]
    }

    var encodedAuxiliaryFields: [String: Any] {
        var encodedData: [Any] = []

        let hasFieldThree = isAuxiliaryFieldThreeOn
        let hasFieldTwo = isAuxiliaryFieldTwoOn || hasFieldThree
        let hasFieldOne = auxiliaryFieldOneLabel != "" || auxiliaryFieldOneText != "" || hasFieldTwo

        if hasFieldOne {
            let auxiliaryField1 = passFieldDict(
                key: "auxiliary1",
                label: auxiliaryFieldOneLabel,
                text: auxiliaryFieldOneText,
                isCurrency: isCurrencyFieldsOn && isAuxiliaryFieldOneCurrency,
                currencyCode: currencyCode,
                blankIfEmpty: true
            )

            encodedData.append(auxiliaryField1)
        }

        if hasFieldTwo {
            let auxiliaryField2 = passFieldDict(
                key: "auxiliary2",
                label: auxiliaryFieldTwoLabel,
                text: auxiliaryFieldTwoText,
                isCurrency: isCurrencyFieldsOn && isAuxiliaryFieldTwoCurrency,
                currencyCode: currencyCode,
                blankIfEmpty: true
            )

            encodedData.append(auxiliaryField2)
        }

        if hasFieldThree {
            let auxiliaryField3 = passFieldDict(
                key: "auxiliary3",
                label: auxiliaryFieldThreeLabel,
                text: auxiliaryFieldThreeText,
                isCurrency: isCurrencyFieldsOn && isAuxiliaryFieldThreeCurrency,
                currencyCode: currencyCode,
                blankIfEmpty: true
            )

            encodedData.append(auxiliaryField3)
        }

        return [
            "auxiliaryFields": encodedData,
        ]
    }
}

// Builds a single PassKit field dictionary, encoding it as a currency amount ("currencyCode" + numeric
// "value") when isCurrency is true, or as a plain string value otherwise.
func passFieldDict(key: String, label: String, text: String, isCurrency: Bool, currencyCode: String, blankIfEmpty: Bool = false) -> [String: Any] {
    var field: [String: Any] = [
        "key": key,
        "label": label,
    ]

    if isCurrency {
        field["currencyCode"] = currencyCode
        field["value"] = currencyFieldValue(text)
    } else {
        field["value"] = blankIfEmpty && text.isEmpty ? " " : text
    }

    return field
}
