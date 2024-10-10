import Foundation
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
func generatePass(passObject: PassObject) -> Bool {
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
        passData.merge(populatePass(passObject: passObject)) { current, _ in current }
        let jsonData = try JSONSerialization.data(withJSONObject: passData, options: .prettyPrinted)
        try jsonData.write(to: fileURL)
        savePNGToDirectory(destinationDirectory: passDirectory)

        try zipDirectory(uuid: passObject.id)

        return true
    } catch {
        return false
    }
}

func zipDirectory(uuid: UUID) throws {
    let fileManager = FileManager()
    let passDirectory = URL.documentsDirectory.appending(path: "\(uuid.uuidString).pass")
    let pkpassDirectory = URL.documentsDirectory.appending(path: "\(uuid.uuidString).pkpass")

    guard let archive = Archive(url: pkpassDirectory, accessMode: .create) else {
        print("Unable to create zip file at path: \(pkpassDirectory.path)")
        return
    }

    let directoryContents = try fileManager.contentsOfDirectory(at: passDirectory, includingPropertiesForKeys: nil)

    for fileURL in directoryContents {
        try archive.addEntry(with: fileURL.lastPathComponent, relativeTo: fileURL.deletingLastPathComponent(), compressionMethod: .deflate)
    }
}

// Returns encoded JSON data with the required information for an identificationPass
func populatePass(passObject: PassObject) -> [String: Any] {
    var encodedData: [String: Any]

    switch passObject.passType {
    case PassType.identificationPass:
        encodedData = encodeIdentificationPass(passObject: passObject)
    case PassType.barcodePass:
        encodedData = encodeBarcodePass(passObject: passObject)
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
        "generic": [data],
    ]

    return generic
}

func encodeBarcodePass(passObject: PassObject) -> [String: Any] {
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
            "value": "asdfasdfasdf",
        ]

        let data: [String: Any] = [
            "barcode": [barcodeFields],
            "primaryFields": [primaryFields],
        ]

        let generic: [String: Any] = [
            "generic": data,
        ]
        return generic
    }

    // Custom case where the barcode must be represented as an image
    else { return [:] }
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
        "value": passObject.name,
    ]

    let data: [String: Any] = [
        "barcode": [barcodeFields],
        "primaryFields": [primaryFields],
    ]

    let generic: [String: Any] = [
        "generic": [data],
    ]
    return generic
    // Custom case where the QR code must be represented as an image
}

func savePNGToDirectory(destinationDirectory: URL) {
    // Create the destination URL by appending the image name to the destination directory
    let sourceURL = Bundle.main.url(forResource: "DefaultPassIcon", withExtension: "png")
    let destinationURL = destinationDirectory.appendingPathComponent("icon.png")

    do {
        // Copy the file to the destination
        try FileManager.default.copyItem(at: sourceURL!, to: destinationURL)
        print("Image saved successfully at \(destinationURL.path)")
    } catch {
        print("Error saving image: \(error.localizedDescription)")
    }
}
