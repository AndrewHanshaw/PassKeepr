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
    "passTypeIdentifier": "pass.com.hanshaw.passKeepr",
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
        passData.merge(["description": passObject.description]) { _, _ in }
        passData.merge(["serialNumber": passObject.id.uuidString]) { _, _ in }
        passData.merge(["foregroundColor": passObject.foregroundColor.toRGBString()]) { _, _ in }
        passData.merge(["backgroundColor": passObject.backgroundColor.toRGBString()]) { _, _ in }
        passData.merge(["labelColor": passObject.labelColor.toRGBString()]) { _, _ in }
        if !passObject.associatedStoreIdentifiers.isEmpty {
            passData.merge(["associatedStoreIdentifiers": passObject.associatedStoreIdentifiers]) { _, _ in }
        }

        // Add customizable data to the pass
        var data: [String: Any] = [:]

        // A primary field with a strip image *is* strictly allowed by PassKit, however it looks horrible, so I'm just disabling it for now to avoid having to even think about it
        if !shouldStripImageBeAddedToPass(passObject: passObject) && !passObject.isCustomStripImageOn {
            let primaryFields: [String: Any] = [
                "key": passObject.primaryFieldLabel,
                "label": passObject.primaryFieldLabel,
                "value": passObject.primaryFieldText,
            ]

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
                barcodeFields = [
                    "message": passObject.barcodeString,
                    "format": "PKBarcodeFormatQR",
                    "messageEncoding": "iso-8859-1",
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

        if passObject.thumbnailImage != Data(), passStyleString == "generic" {
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

func encodeHeaderFields(passObject: PassObject) -> [String: Any] {
    var encodedData: [Any] = []

    if passObject.headerFieldOneLabel != "" || passObject.headerFieldOneText != "" {
        let headerField1: [String: Any] = [
            "key": passObject.headerFieldOneLabel,
            "label": passObject.headerFieldOneLabel,
            "value": passObject.headerFieldOneText,
        ]

        encodedData.append(headerField1)
    }

    if passObject.isHeaderFieldTwoOn == true {
        let headerField2: [String: Any] = [
            "key": passObject.headerFieldTwoLabel,
            "label": passObject.headerFieldTwoLabel,
            "value": passObject.headerFieldTwoText,
        ]

        encodedData.append(headerField2)
    }

    let headerFields: [String: Any] = [
        "headerFields": encodedData,
    ]

    return headerFields
}

func encodeSecondaryFields(passObject: PassObject) -> [String: Any] {
    var encodedData: [Any] = []

    if passObject.secondaryFieldOneLabel != "", passObject.secondaryFieldOneText != "" {
        let secondaryField1: [String: Any] = [
            "key": passObject.secondaryFieldOneLabel,
            "label": passObject.secondaryFieldOneLabel,
            "value": passObject.secondaryFieldOneText,
        ]

        encodedData.append(secondaryField1)
    }

    if passObject.isSecondaryFieldTwoOn == true {
        let secondaryField2: [String: Any] = [
            "key": passObject.secondaryFieldTwoLabel,
            "label": passObject.secondaryFieldTwoLabel,
            "value": passObject.secondaryFieldTwoText,
        ]

        encodedData.append(secondaryField2)
    }

    if passObject.isSecondaryFieldThreeOn == true {
        let secondaryField3: [String: Any] = [
            "key": passObject.secondaryFieldThreeLabel,
            "label": passObject.secondaryFieldThreeLabel,
            "value": passObject.secondaryFieldThreeText,
        ]

        encodedData.append(secondaryField3)
    }

    let secondaryFields: [String: Any] = [
        "secondaryFields": encodedData,
    ]

    return secondaryFields
}

func encodeAuxiliaryFields(passObject: PassObject) -> [String: Any] {
    var encodedData: [Any] = []

    if passObject.auxiliaryFieldOneLabel != "", passObject.auxiliaryFieldOneText != "" {
        let auxiliaryField1: [String: Any] = [
            "key": passObject.auxiliaryFieldOneLabel,
            "label": passObject.auxiliaryFieldOneLabel,
            "value": passObject.auxiliaryFieldOneText,
        ]

        encodedData.append(auxiliaryField1)
    }

    if passObject.isAuxiliaryFieldTwoOn == true {
        let auxiliaryField2: [String: Any] = [
            "key": passObject.auxiliaryFieldTwoLabel,
            "label": passObject.auxiliaryFieldTwoLabel,
            "value": passObject.auxiliaryFieldTwoText,
        ]

        encodedData.append(auxiliaryField2)
    }

    if passObject.isAuxiliaryFieldThreeOn == true {
        let auxiliaryField3: [String: Any] = [
            "key": passObject.auxiliaryFieldThreeLabel,
            "label": passObject.auxiliaryFieldThreeLabel,
            "value": passObject.auxiliaryFieldThreeText,
        ]

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
    if passObject.barcodeType != BarcodeType.qr && (passObject.barcodeType.isEnteredBarcodeValueValid(string: passObject.barcodeString) || passObject.isCustomStripImageOn) {
        return true
    } else {
        return false
    }
}

func shouldStripImageBeAddedToPass(passObject: PassObject) -> Bool {
    if (passObject.isCustomStripImageOn) && (passObject.stripImage != Data()) || getIsStripImageSupported(passObject: passObject) {
        return true
    } else {
        return false
    }
}
