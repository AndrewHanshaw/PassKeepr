import Foundation
import UIKit
import ZIPFoundation

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
    let passDirectory = URL.documentsDirectory.appending(path: "\(passObject.id.uuidString).pass")

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

        var passStyleString: String

        // Strip image takes priority for pass style
        if passObject.stripImage != Data() {
            passStyleString = "storeCard"
        } else if passObject.backgroundImage != Data() {
            // If there is a background image
            passStyleString = "eventTicket"
        } else {
            // Default to generic
            passStyleString = "generic"
        }

        var passStyle: [String: Any] = [passStyleString: data]

        var barcodeFields: [String: Any] = [:]

        if passObject.barcodeType == BarcodeType.code128 || passObject.barcodeType == BarcodeType.pdf417 || passObject.barcodeType == BarcodeType.qr {
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

        savePNGToDirectory(pngData: passObject.passIcon, destinationDirectory: passDirectory, fileName: "icon")

        if shouldStripImageBeAddedToPass(passObject: passObject) {
            if passStyleString != "storeCard" {
                print("PassObject has stripImage but is not of style 'storeCard'")
            }

            if passObject.backgroundImage != Data() {
                print("PassObject has background image and strip image. Not saving strip image")
            } else {
//                savePNGToDirectory(pngData: (UIImage(data: passObject.stripImage)?.resizeToFit2(maxWidth: 1125, maxHeight: 432).pngData()!)!, destinationDirectory: passDirectory, fileName: "strip")
                savePNGToDirectory(pngData: passObject.stripImage, destinationDirectory: passDirectory, fileName: "strip")
//                savePNGToDirectory(pngData: passObject.stripImage, destinationDirectory: passDirectory, fileName: "strip@2x")
            }
        }

        if shouldBackgroundImageBeAddedToPass(passObject: passObject) {
            if passStyleString != "eventTicket" {
                print("PassObject should have background image but is not of style 'eventTicket'")
            }
            savePNGToDirectory(pngData: UIImage(data: passObject.backgroundImage)!.resize(targetSize: CGSize(width: 112, height: 142))!.pngData()!, destinationDirectory: passDirectory, fileName: "background")
        }

        if passObject.logoImage != Data() {
            savePNGToDirectory(pngData: (UIImage(data: passObject.logoImage)?.resizeToFit().pngData()!)!, destinationDirectory: passDirectory, fileName: "logo")
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
    let passDirectory = URL.documentsDirectory.appending(path: "\(uuid.uuidString).pass")
    let pkpassDirectory = URL.documentsDirectory.appending(path: "\(uuid.uuidString).pkpass")

    guard let archive = Archive(url: pkpassDirectory, accessMode: .create) else {
        print("Unable to create zip file at path: \(pkpassDirectory.path)")
        return nil
    }

    let directoryContents = try fileManager.contentsOfDirectory(at: passDirectory, includingPropertiesForKeys: nil)

    for fileURL in directoryContents {
        try archive.addEntry(with: fileURL.lastPathComponent, relativeTo: fileURL.deletingLastPathComponent(), compressionMethod: .deflate)
    }

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
    if /* (passObject.stripImage == Data()) && */ (passObject.barcodeType == BarcodeType.code128) || (passObject.barcodeType == BarcodeType.pdf417) || (passObject.barcodeType == BarcodeType.qr) || (passObject.barcodeType == BarcodeType.none) {
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
    if (passObject.stripImage != Data()) && getIsStripImageSupported(passObject: passObject) {
        return true
    } else {
        return false
    }
}
