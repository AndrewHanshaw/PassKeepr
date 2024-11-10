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
        passData.merge(["description": passObject.description]) { current, _ in current }
        passData.merge(["serialNumber": passObject.id.uuidString]) { current, _ in current }
        passData.merge(["foregroundColor": passObject.foregroundColor.toRGBString]) { current, _ in current }
        passData.merge(["backgroundColor": passObject.backgroundColor.toRGBString]) { current, _ in current }
        passData.merge(populatePass(passObject: passObject, passDirectory: passDirectory)) { current, _ in current }
        let jsonData = try JSONSerialization.data(withJSONObject: passData, options: .prettyPrinted)
        try jsonData.write(to: fileURL)
        savePNGToDirectory(pngData: passObject.passIcon, destinationDirectory: passDirectory, fileName: "icon")

        if passObject.stripImage != Data() {
            savePNGToDirectory(pngData: passObject.stripImage, destinationDirectory: passDirectory, fileName: "strip")
            savePNGToDirectory(pngData: passObject.stripImage, destinationDirectory: passDirectory, fileName: "strip@2x")
        }

        if shouldBackgroundImageBeAddedToPass(passObject: passObject) {
            savePNGToDirectory(pngData: passObject.backgroundImage, destinationDirectory: passDirectory, fileName: "background@2x")
            savePNGToDirectory(pngData: resizeImage(image: UIImage(data: passObject.backgroundImage)!, targetSize: CGSize(width: 112, height: 142))!.pngData()!, destinationDirectory: passDirectory, fileName: "background")
        }

        if passObject.logoImage != Data() {
            savePNGToDirectory(pngData: passObject.logoImage, destinationDirectory: passDirectory, fileName: "logo")
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

// Returns encoded JSON data with the required information for an identificationPass
func populatePass(passObject: PassObject, passDirectory: URL) -> [String: Any] {
    var encodedData: [String: Any]

    switch passObject.passType {
    case PassType.identificationPass:
        encodedData = encodeIdentificationPass(passObject: passObject)
    case PassType.barcodePass:
        encodedData = encodeBarcodePass(passObject: passObject, passDirectory: passDirectory)
    case PassType.qrCodePass:
        encodedData = encodeQrCodePass(passObject: passObject)
    default:
        encodedData = [:]
    }

    return encodedData
}

func encodeIdentificationPass(passObject: PassObject) -> [String: Any] {
    let primaryFields: [String: Any] = [
        "key": "name",
        "label": "NAME",
        "value": passObject.name,
    ]

    let secondaryFields: [String: Any] = [
        "key": "id",
        "label": "ID",
        "value": passObject.identificationString,
    ]

    let data: [String: Any] = [
        "primaryFields": [primaryFields],
        "secondaryFields": [secondaryFields],
    ]

    let generic: [String: Any] = [
        "generic": data,
    ]

    return generic
}

func encodeBarcodePass(passObject: PassObject, passDirectory _: URL) -> [String: Any] {
    // Nominal case where the barcode type is directly supported by PassKit
    if passObject.barcodeType == BarcodeType.code128 {
        let barcodeFields: [String: Any] = [
            "message": passObject.barcodeString,
            "format": "PKBarcodeFormatCode128",
            "messageEncoding": "iso-8859-1",
        ]

        let primaryFields: [String: Any] = [
            "key": "name",
            "label": "NAME",
            "value": passObject.passName,
        ]

        let data: [String: Any] = [
            "primaryFields": [primaryFields],
        ]

        if shouldBackgroundImageBeAddedToPass(passObject: passObject) {
            let eventTicket: [String: Any] = [
                "eventTicket": data,
                "barcode": barcodeFields,
            ]
            return eventTicket
        } else {
            let generic: [String: Any] = [
                "generic": data,
                "barcode": barcodeFields,
            ]
            return generic
        }
    }

    // Custom case where the barcode must be represented as an image
    else {
        let secondaryFields: [String: Any] = [
            "key": "name",
            "label": "NAME",
            "value": passObject.passName,
        ]

        let data: [String: Any] = [
            "secondaryFields": [secondaryFields],
        ]

        let storeCard: [String: Any] = [
            "storeCard": data,
        ]

        return storeCard
    }
}

func encodeQrCodePass(passObject: PassObject) -> [String: Any] {
    // Nominal case where the QR code is directly supported by PassKit
    // TODO: altText support?
    let barcodeFields: [String: Any] = [
        "message": passObject.qrCodeString,
        "format": "PKBarcodeFormatQR",
        "messageEncoding": "iso-8859-1",
    ]

    let primaryFields: [String: Any] = [
        "key": "name",
        "label": "NAME",
        "value": passObject.passName,
    ]

    let data: [String: Any] = [
        "primaryFields": [primaryFields],
    ]

    let generic: [String: Any] = [
        "generic": data,
        "barcode": barcodeFields,
    ]
    return generic
    // Custom case where the QR code must be represented as an image
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
    if (passObject.stripImage == Data()) && ((passObject.barcodeType == BarcodeType.code128) || (passObject.passType == PassType.qrCodePass)) {
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
