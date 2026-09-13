import Foundation
import UIKit
import ZIPFoundation

// Helper: save 1x and optional @2x/@3x variants from PassObject image
func saveImageVariants(from data: Data, name: String, passDirectory: URL, maxWidth: CGFloat, maxHeight: CGFloat) {
    guard let ui = UIImage(data: data) else {
        // Not a decodable image - write raw data
        savePNGToDirectory(pngData: data, destinationDirectory: passDirectory, fileName: name)
        return
    }

    // Prefer actual pixel dims from cgImage when available
    let srcPixelW: CGFloat = (ui.cgImage != nil) ? CGFloat(ui.cgImage!.width) : (ui.size.width * ui.scale)
    let srcPixelH: CGFloat = (ui.cgImage != nil) ? CGFloat(ui.cgImage!.height) : (ui.size.height * ui.scale)

    // Debug: initial sizes
    print("[saveImageVariants] name=\(name) srcPixels=\(Int(srcPixelW))x\(Int(srcPixelH)) ui.size=\(ui.size) ui.scale=\(ui.scale)")

    // Thresholds for 1x/2x/3x
    let t1W = maxWidth
    let t1H = maxHeight
    let t2W = maxWidth * 2.0
    let t2H = maxHeight * 2.0
    let t3W = maxWidth * 3.0
    let t3H = maxHeight * 3.0
    print("[saveImageVariants] thresholds: 1x=\(Int(t1W))x\(Int(t1H)) 2x=\(Int(t2W))x\(Int(t2H)) 3x=\(Int(t3W))x\(Int(t3H))")

    // Helper to save data or resized image for a given pixel size
    func saveResized(_ targetW: Int, _ targetH: Int, fileSuffix: String?) {
        if let resized = ui.resize(targetSize: CGSize(width: CGFloat(targetW), height: CGFloat(targetH)))?.pngData() {
            let fileName = fileSuffix != nil ? "\(name)@\(fileSuffix!)" : name
            savePNGToDirectory(pngData: resized, destinationDirectory: passDirectory, fileName: fileName)
        }
    }

    // Determine classification and generate accordingly using per-axis (OR) checks
    print("[saveImageVariants] per-axis thresholds check: 1x=\(Int(t1W))x\(Int(t1H)) 2x=\(Int(t2W))x\(Int(t2H)) 3x=\(Int(t3W))x\(Int(t3H))")

    // Any axis above 2x -> classify as 3x
    if srcPixelW >= t2W || srcPixelH >= t2H {
        print("[saveImageVariants] classification=3x (axis-based)")
        let final3xW: Int
        let final3xH: Int

        // If the image is above 3x on any axis, downscale it to fit within 3x max dimensions while preserving aspect ratio
        // Otherwise, keep original dimensions for 3x variant
        if (srcPixelW > t3W) || (srcPixelH > t3H) {
            let downscale = min(t3W / srcPixelW, t3H / srcPixelH)
            print("[saveImageVariants] Downscaling image. downscale=\(downscale)")
            final3xW = max(1, Int((srcPixelW * downscale).rounded()))
            final3xH = max(1, Int((srcPixelH * downscale).rounded()))
        } else {
            final3xW = max(1, Int(srcPixelW.rounded()))
            final3xH = max(1, Int(srcPixelH.rounded()))
        }

        print("[saveImageVariants] final3x=\(final3xW)x\(final3xH)")
        // If the original image is already the correct dimensions for 3x, save it directly (don't bother resizing and risk quality loss from an encode/decode cycle)
        // Otherwise, resize it to 3x dimensions before saving
        if final3xW == Int(srcPixelW.rounded()), final3xH == Int(srcPixelH.rounded()) {
            print("[saveImageVariants] saving original as \(name)@3x.png")
            savePNGToDirectory(pngData: data, destinationDirectory: passDirectory, fileName: "\(name)@3x")
        } else if let png3 = ui.resize(targetSize: CGSize(width: CGFloat(final3xW), height: CGFloat(final3xH)))?.pngData() {
            print("[saveImageVariants] saving resized 3x \(final3xW)x\(final3xH) as \(name)@3x.png")
            savePNGToDirectory(pngData: png3, destinationDirectory: passDirectory, fileName: "\(name)@3x")
        }

        // Derive 2x and 1x images from the 3x variant
        let target2xW = max(1, Int((CGFloat(final3xW) * 2.0 / 3.0).rounded()))
        let target2xH = max(1, Int((CGFloat(final3xH) * 2.0 / 3.0).rounded()))
        saveResized(target2xW, target2xH, fileSuffix: "2x")

        let target1xW = max(1, Int((CGFloat(final3xW) / 3.0).rounded()))
        let target1xH = max(1, Int((CGFloat(final3xH) / 3.0).rounded()))
        saveResized(target1xW, target1xH, fileSuffix: nil)

        print("[saveImageVariants] derived 2x=\(target2xW)x\(target2xH) 1x=\(target1xW)x\(target1xH)")

    } else if srcPixelW >= t1W || srcPixelH >= t1H { // Any axis above 1x -> classify as 2x
        print("[saveImageVariants] classification=2x (axis-based)")
        let final2xW = max(1, Int(srcPixelW.rounded()))
        let final2xH = max(1, Int(srcPixelH.rounded()))
        savePNGToDirectory(pngData: data, destinationDirectory: passDirectory, fileName: "\(name)@2x")
        print("[saveImageVariants] saving original as \(name)@2x.png (source dims) \(final2xW)x\(final2xH)")

        let target1xW = max(1, Int((CGFloat(final2xW) / 2.0).rounded()))
        let target1xH = max(1, Int((CGFloat(final2xH) / 2.0).rounded()))
        saveResized(target1xW, target1xH, fileSuffix: nil)
        print("[saveImageVariants] derived 1x=\(target1xW)x\(target1xH)")

    } else { // Smaller than 1x: only save as 1x
        print("[saveImageVariants] classification=smaller_than_1x — saving only 1x")
        savePNGToDirectory(pngData: data, destinationDirectory: passDirectory, fileName: name)
    }
}

// Fields required by every PassKit pass
// These are not customizable by the user, so they're kept separate from the PassObject used to otherwise build the pass
let requiredFields: [String: Any] = [
    "formatVersion": 1,
    "teamIdentifier": "NZDS56Z4Q9",
    "organizationName": "PassKeepr",
]

// Initializes a new PassKit pass for the given pass
func generatePass(passObject: PassObject) -> URL? {
    let fileManager = FileManager.default
    let passDirectory = URL.applicationSupportDirectory.appending(path: "\(passObject.id.uuidString).pass")

    do {
        // Create the directory for the pass
        try fileManager.createDirectory(at: passDirectory, withIntermediateDirectories: true)

        // Add a pass.json to it
        let fileURL = passDirectory.appendingPathComponent("pass.json")
        fileManager.createFile(atPath: fileURL.path, contents: Data())

        // Add the required data to the pass
        var passData: [String: Any] = requiredFields
        passData["passTypeIdentifier"] = "pass.com.hanshaw.passKeepr.\(passObject.group)"
        passData.merge(["description": passObject.description]) { _, _ in }
        passData.merge(["serialNumber": passObject.id.uuidString]) { _, _ in }
        passData.merge(["foregroundColor": passObject.foregroundColor.toRGBString()]) { _, _ in }
        passData.merge(["backgroundColor": passObject.backgroundColor.toRGBString()]) { _, _ in }
        passData.merge(["labelColor": passObject.labelColor.toRGBString()]) { _, _ in }
        if passObject.hasExpirationDate {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            passData.merge(["expirationDate": formatter.string(from: passObject.expirationDate)]) { _, _ in }
        }
        if !passObject.locations.isEmpty {
            let encoded: [[String: Any]] = passObject.locations.map { loc in
                var d: [String: Any] = ["latitude": loc.latitude, "longitude": loc.longitude]
                if !loc.relevantText.isEmpty { d["relevantText"] = loc.relevantText }
                return d
            }
            passData.merge(["locations": encoded]) { _, _ in }
        }
        if !passObject.associatedStoreIdentifiers.isEmpty {
            passData.merge(["associatedStoreIdentifiers": passObject.associatedStoreIdentifiers]) { _, _ in }
        }

        // Add customizable data to the pass
        var data: [String: Any] = [:]

        // A primary field with a strip image *is* strictly allowed by PassKit, however it looks horrible, so I'm just disabling it for now to avoid having to even think about it
        if !shouldStripImageBeAddedToPass(passObject: passObject) && !passObject.isCustomStripImageOn {
            let primaryFields: [String: Any] = passFieldDict(
                key: "primary",
                label: passObject.primaryFieldLabel,
                text: passObject.primaryFieldText,
                isCurrency: passObject.isCurrencyFieldsOn && passObject.isPrimaryFieldCurrency,
                currencyCode: passObject.currencyCode
            )

            data.merge(["primaryFields": [primaryFields]]) { _, _ in }
        }

        if passObject.headerFieldOneLabel != "" || passObject.headerFieldOneText != "" || passObject.isHeaderFieldTwoOn {
            data.merge(encodeHeaderFields(passObject: passObject)) { _, _ in }
        }

        if passObject.secondaryFieldOneLabel != "" || passObject.secondaryFieldOneText != "" || passObject.isSecondaryFieldTwoOn || passObject.isSecondaryFieldThreeOn {
            data.merge(encodeSecondaryFields(passObject: passObject)) { _, _ in }
        }

        if !passObject.isCustomStripImageOn && (passObject.auxiliaryFieldOneLabel != "" || passObject.auxiliaryFieldOneText != "" || passObject.isAuxiliaryFieldTwoOn || passObject.isAuxiliaryFieldThreeOn) {
            data.merge(encodeAuxiliaryFields(passObject: passObject)) { _, _ in }
        }

        var passStyleString: String

        // Strip image takes priority for pass style
        if passObject.stripImage != Data() {
            if passObject.thumbnailImage != Data() && !passObject.isCustomStripImageOn {
                passStyleString = "generic"
            } else {
                passStyleString = "storeCard"
            }
        } else if passObject.backgroundImage != Data() {
            // If there is a background image
            passStyleString = "eventTicket"
        } else {
            // Default to generic
            passStyleString = "generic"
        }

        var passStyle: [String: Any] = [passStyleString: data]

        var barcodeFields: [String: Any] = [:]

        if passObject.barcodeType == BarcodeType.code128 || passObject.barcodeType == BarcodeType.pdf417 || passObject.barcodeType == BarcodeType.qr, passObject.barcodeString != "" {
            if passObject.barcodeType == BarcodeType.code128 {
                barcodeFields = [
                    "message": passObject.barcodeString,
                    "format": "PKBarcodeFormatCode128",
                    "messageEncoding": "iso-8859-1",
                ]
            } else if passObject.barcodeType == BarcodeType.pdf417 {
                barcodeFields = [
                    "message": passObject.barcodeString,
                    "format": "PKBarcodeFormatPDF417",
                    "messageEncoding": "iso-8859-1",
                ]
            } else if passObject.barcodeType == BarcodeType.qr {
                let safeEncoding = passObject.qrCodeEncoding.isCompatible(with: passObject.barcodeString)
                    ? passObject.qrCodeEncoding
                    : QrCodeEncoding.minimumEncoding(for: passObject.barcodeString)
                barcodeFields = [
                    "message": passObject.barcodeString,
                    "format": "PKBarcodeFormatQR",
                    "messageEncoding": safeEncoding.ianaEncodingName,
                ]
            }

            if passObject.altText != "" {
                barcodeFields.merge(["altText": passObject.altText]) { _, _ in }
            }

            passStyle.merge(["barcode": barcodeFields]) { _, _ in }
        }

        passData.merge(passStyle) { _, _ in }

        let jsonData = try JSONSerialization.data(withJSONObject: passData, options: .prettyPrinted)
        try jsonData.write(to: fileURL)

        saveImageVariants(from: passObject.passIcon, name: "icon", passDirectory: passDirectory, maxWidth: PassKitConstants.IconImage.width, maxHeight: PassKitConstants.IconImage.height)

        if shouldStripImageBeAddedToPass(passObject: passObject) {
            if passStyleString != "storeCard" {
                print("PassObject has stripImage but is not of style 'storeCard'")
            }

            if passObject.backgroundImage != Data() {
                print("PassObject has background image and strip image. Not saving strip image")
            } else {
                saveSingleScaleImage(from: passObject.stripImage, name: "strip", passDirectory: passDirectory, maxWidth: PassKitConstants.StripImage.width, maxHeight: PassKitConstants.StripImage.height)
            }
        }

        if shouldBackgroundImageBeAddedToPass(passObject: passObject) {
            if passStyleString != "eventTicket" {
                print("PassObject should have background image but is not of style 'eventTicket'")
            }
            saveSingleScaleImage(from: passObject.backgroundImage, name: "background", passDirectory: passDirectory, maxWidth: PassKitConstants.BackgroundImage.width, maxHeight: PassKitConstants.BackgroundImage.height)
        }

        if passObject.logoImage != Data() {
            saveImageVariants(from: passObject.logoImage, name: "logo", passDirectory: passDirectory, maxWidth: PassKitConstants.LogoImage.width, maxHeight: PassKitConstants.LogoImage.height)
        }

        if passObject.thumbnailImage != Data(), passStyleString == "generic" || passStyleString == "eventTicket" {
            saveImageVariants(from: passObject.thumbnailImage, name: "thumbnail", passDirectory: passDirectory, maxWidth: PassKitConstants.ThumbnailImage.width, maxHeight: PassKitConstants.ThumbnailImage.height)
        }

        if let pkpassDir = try zipDirectory(uuid: passObject.id) {
            return pkpassDir
        } else {
            return nil
        }

    } catch {
        return nil
    }
}

func zipDirectory(uuid: UUID) throws -> URL? {
    let fileManager = FileManager()
    let passDirectory = URL.applicationSupportDirectory.appending(path: "\(uuid.uuidString).pass")
    let pkpassDirectory = URL.applicationSupportDirectory.appending(path: "\(uuid.uuidString).pkpass")

    let archive: Archive
    do {
        archive = try Archive(url: pkpassDirectory, accessMode: .create)
    } catch {
        print("Unable to create zip file at path: \(pkpassDirectory.path): \(error)")
        return nil
    }

    let directoryContents = try fileManager.contentsOfDirectory(at: passDirectory, includingPropertiesForKeys: nil)

    for fileURL in directoryContents {
        try archive.addEntry(with: fileURL.lastPathComponent, relativeTo: fileURL.deletingLastPathComponent(), compressionMethod: .deflate)
    }

    // Clean up the staging .pass directory — not needed after zipping
    try? fileManager.removeItem(at: passDirectory)

    return pkpassDirectory
}

// Converts a user-entered field value into a decimal amount suitable for a PassKit currency field,
// tolerating common formatting characters (currency symbols, thousands separators, whitespace).
func currencyFieldValue(_ text: String) -> Double {
    let cleaned = text
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: ",", with: "")
        .filter { $0.isNumber || $0 == "." || $0 == "-" }

    return Double(cleaned) ?? 0
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

func encodeHeaderFields(passObject: PassObject) -> [String: Any] {
    var encodedData: [Any] = []

    if passObject.headerFieldOneLabel != "" || passObject.headerFieldOneText != "" {
        let headerField1 = passFieldDict(
            key: "header1",
            label: passObject.headerFieldOneLabel,
            text: passObject.headerFieldOneText,
            isCurrency: passObject.isCurrencyFieldsOn && passObject.isHeaderFieldOneCurrency,
            currencyCode: passObject.currencyCode
        )

        encodedData.append(headerField1)
    }

    if passObject.isHeaderFieldTwoOn == true {
        let headerField2 = passFieldDict(
            key: "header2",
            label: passObject.headerFieldTwoLabel,
            text: passObject.headerFieldTwoText,
            isCurrency: passObject.isCurrencyFieldsOn && passObject.isHeaderFieldTwoCurrency,
            currencyCode: passObject.currencyCode
        )

        encodedData.append(headerField2)
    }

    let headerFields: [String: Any] = [
        "headerFields": encodedData,
    ]

    return headerFields
}

func encodeSecondaryFields(passObject: PassObject) -> [String: Any] {
    var encodedData: [Any] = []

    let hasFieldThree = passObject.isSecondaryFieldThreeOn
    let hasFieldTwo = passObject.isSecondaryFieldTwoOn || hasFieldThree
    let hasFieldOne = passObject.secondaryFieldOneLabel != "" || passObject.secondaryFieldOneText != "" || hasFieldTwo

    if hasFieldOne {
        let secondaryField1 = passFieldDict(
            key: "secondary1",
            label: passObject.secondaryFieldOneLabel,
            text: passObject.secondaryFieldOneText,
            isCurrency: passObject.isCurrencyFieldsOn && passObject.isSecondaryFieldOneCurrency,
            currencyCode: passObject.currencyCode,
            blankIfEmpty: true
        )

        encodedData.append(secondaryField1)
    }

    if hasFieldTwo {
        let secondaryField2 = passFieldDict(
            key: "secondary2",
            label: passObject.secondaryFieldTwoLabel,
            text: passObject.secondaryFieldTwoText,
            isCurrency: passObject.isCurrencyFieldsOn && passObject.isSecondaryFieldTwoCurrency,
            currencyCode: passObject.currencyCode,
            blankIfEmpty: true
        )

        encodedData.append(secondaryField2)
    }

    if hasFieldThree {
        let secondaryField3 = passFieldDict(
            key: "secondary3",
            label: passObject.secondaryFieldThreeLabel,
            text: passObject.secondaryFieldThreeText,
            isCurrency: passObject.isCurrencyFieldsOn && passObject.isSecondaryFieldThreeCurrency,
            currencyCode: passObject.currencyCode,
            blankIfEmpty: true
        )

        encodedData.append(secondaryField3)
    }

    let secondaryFields: [String: Any] = [
        "secondaryFields": encodedData,
    ]

    return secondaryFields
}

func encodeAuxiliaryFields(passObject: PassObject) -> [String: Any] {
    var encodedData: [Any] = []

    let hasFieldThree = passObject.isAuxiliaryFieldThreeOn
    let hasFieldTwo = passObject.isAuxiliaryFieldTwoOn || hasFieldThree
    let hasFieldOne = passObject.auxiliaryFieldOneLabel != "" || passObject.auxiliaryFieldOneText != "" || hasFieldTwo

    if hasFieldOne {
        let auxiliaryField1 = passFieldDict(
            key: "auxiliary1",
            label: passObject.auxiliaryFieldOneLabel,
            text: passObject.auxiliaryFieldOneText,
            isCurrency: passObject.isCurrencyFieldsOn && passObject.isAuxiliaryFieldOneCurrency,
            currencyCode: passObject.currencyCode,
            blankIfEmpty: true
        )

        encodedData.append(auxiliaryField1)
    }

    if hasFieldTwo {
        let auxiliaryField2 = passFieldDict(
            key: "auxiliary2",
            label: passObject.auxiliaryFieldTwoLabel,
            text: passObject.auxiliaryFieldTwoText,
            isCurrency: passObject.isCurrencyFieldsOn && passObject.isAuxiliaryFieldTwoCurrency,
            currencyCode: passObject.currencyCode,
            blankIfEmpty: true
        )

        encodedData.append(auxiliaryField2)
    }

    if hasFieldThree {
        let auxiliaryField3 = passFieldDict(
            key: "auxiliary3",
            label: passObject.auxiliaryFieldThreeLabel,
            text: passObject.auxiliaryFieldThreeText,
            isCurrency: passObject.isCurrencyFieldsOn && passObject.isAuxiliaryFieldThreeCurrency,
            currencyCode: passObject.currencyCode,
            blankIfEmpty: true
        )

        encodedData.append(auxiliaryField3)
    }

    let auxiliaryFields: [String: Any] = [
        "auxiliaryFields": encodedData,
    ]

    return auxiliaryFields
}

// Saves an image as a single 1x PNG, downscaling to fit within the given max dimensions if necessary
func saveSingleScaleImage(from data: Data, name: String, passDirectory: URL, maxWidth: CGFloat, maxHeight: CGFloat) {
    guard let ui = UIImage(data: data), let cgImage = ui.cgImage else {
        savePNGToDirectory(pngData: data, destinationDirectory: passDirectory, fileName: name)
        return
    }

    let srcW = CGFloat(cgImage.width)
    let srcH = CGFloat(cgImage.height)

    if srcW <= maxWidth, srcH <= maxHeight {
        savePNGToDirectory(pngData: data, destinationDirectory: passDirectory, fileName: name)
    } else {
        let scale = min(maxWidth / srcW, maxHeight / srcH)
        let targetW = max(1, Int((srcW * scale).rounded()))
        let targetH = max(1, Int((srcH * scale).rounded()))
        if let resized = ui.resize(targetSize: CGSize(width: targetW, height: targetH))?.pngData() {
            savePNGToDirectory(pngData: resized, destinationDirectory: passDirectory, fileName: name)
        }
    }
}

func savePNGToDirectory(pngData: Data, destinationDirectory: URL, fileName: String) {
    let destinationURL = destinationDirectory.appendingPathComponent("\(fileName).png")

    do {
        try pngData.write(to: destinationURL, options: .atomic)
        print("Image saved successfully at \(destinationURL.path)")
    } catch {
        print("Error saving image: \(error.localizedDescription)")
    }
}

func getIsBackgroundImageSupported(passObject: PassObject) -> Bool {
    if (passObject.barcodeType == BarcodeType.code128) || (passObject.barcodeType == BarcodeType.pdf417) || (passObject.barcodeType == BarcodeType.qr) || (passObject.barcodeType == BarcodeType.none) {
        return true
    } else {
        return false
    }
}

func shouldBackgroundImageBeAddedToPass(passObject: PassObject) -> Bool {
    if (passObject.backgroundImage != Data()) && getIsBackgroundImageSupported(passObject: passObject) {
        return true
    } else {
        return false
    }
}

func getIsStripImageSupported(passObject: PassObject) -> Bool {
    if passObject.barcodeType.isEnteredBarcodeValueValid(string: passObject.barcodeString) || passObject.isCustomStripImageOn {
        return true
    } else {
        return false
    }
}

func shouldStripImageBeAddedToPass(passObject: PassObject) -> Bool {
    guard passObject.stripImage != Data() else { return false }
    return passObject.isCustomStripImageOn || getIsStripImageSupported(passObject: passObject)
}
