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
        passData.merge(["foregroundColor": passObject.foregroundColor.toRGBString()]) { current, _ in current }
        passData.merge(["backgroundColor": passObject.backgroundColor.toRGBString()]) {
            current, _ in current
        }
        passData.merge(["labelColor": passObject.labelColor.toRGBString()]) { current, _ in current }
        passData.merge(populatePass(passObject: passObject)) { current, _ in current }

        let jsonData = try JSONSerialization.data(withJSONObject: passData, options: .prettyPrinted)
        try jsonData.write(to: fileURL)
        savePNGToDirectory(pngData: passObject.passIcon, destinationDirectory: passDirectory, fileName: "icon")

        if passObject.stripImage != Data() {
            savePNGToDirectory(pngData: passObject.stripImage, destinationDirectory: passDirectory, fileName: "strip")
            savePNGToDirectory(pngData: passObject.stripImage, destinationDirectory: passDirectory, fileName: "strip@2x")
        }

        if shouldBackgroundImageBeAddedToPass(passObject: passObject) {
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

func populatePass(passObject: PassObject) -> [String: Any] {
    var encodedData: [String: Any]

    switch passObject.passType {
    case PassType.identificationPass:
        encodedData = encodeIdentificationPass(passObject: passObject)
    case PassType.barcodePass:
        encodedData = encodeBarcodePass(passObject: passObject)
    case PassType.qrCodePass:
        encodedData = encodeQrCodePass(passObject: passObject)
    case PassType.businessCardPass:
        encodedData = encodeBusinessCardPass(passObject: passObject)
    default:
        encodedData = [:]
    }

    return encodedData
}

func encodeHeaderFields(passObject: PassObject) -> [String: Any] {
    var encodedData: [Any] = []
    var headerFields: [String: Any] = [:]

    let headerField1: [String: Any] = [
        "key": passObject.headerFieldOneLabel,
        "label": passObject.headerFieldOneLabel,
        "value": passObject.headerFieldOneText,
    ]

    let headerField2: [String: Any] = [
        "key": passObject.headerFieldTwoLabel,
        "label": passObject.headerFieldTwoLabel,
        "value": passObject.headerFieldTwoText,
    ]

    if passObject.isHeaderFieldOneOn == true {
        encodedData.append(headerField1)
    }

    if passObject.isHeaderFieldTwoOn == true {
        encodedData.append(headerField2)
    }

    headerFields = [
        "headerFields": encodedData,
    ]

    return headerFields
}

func encodeIdentificationPass(passObject: PassObject) -> [String: Any] {
    let primaryFields: [String: Any] = [
        "key": passObject.primaryFieldLabel,
        "label": passObject.primaryFieldLabel,
        "value": passObject.primaryFieldText,
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

func encodeBarcodePass(passObject: PassObject) -> [String: Any] {
    // Nominal case where the barcode type is directly supported by PassKit
    if passObject.barcodeType == BarcodeType.code128 {
        let barcodeFields: [String: Any] = [
            "message": passObject.barcodeString,
            "format": "PKBarcodeFormatCode128",
            "messageEncoding": "iso-8859-1",
        ]

        let primaryFields: [String: Any] = [
            "key": passObject.primaryFieldLabel,
            "label": passObject.primaryFieldLabel,
            "value": passObject.primaryFieldText,
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
            "value": passObject.secondaryFieldOneText,
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
        "key": passObject.primaryFieldLabel,
        "label": passObject.primaryFieldLabel,
        "value": passObject.primaryFieldText,
    ]

    var data: [String: Any] = [
        "primaryFields": [primaryFields],
    ]

    data.merge(encodeHeaderFields(passObject: passObject)) {
        current, _ in current
    }

    let generic: [String: Any] = [
        "generic": data,
        "barcode": barcodeFields,
    ]
    return generic
}

func encodeBusinessCardPass(passObject: PassObject) -> [String: Any] {
    let primaryFields: [String: Any] = [
        "key": passObject.primaryFieldLabel,
        "label": passObject.primaryFieldLabel,
        "value": passObject.primaryFieldText,
    ]

    let nameField: [String: Any] = [
        "key": "name",
        "label": "Name",
        "value": passObject.name,
    ]

    let titleField: [String: Any] = [
        "key": "title",
        "label": "Title",
        "value": passObject.title,
    ]

    let businessNameField: [String: Any] = [
        "key": "business",
        "label": "Business",
        "value": passObject.businessName,
    ]

    let phoneNumberField: [String: Any] = [
        "key": "phone",
        "label": "Phone",
        "value": passObject.phoneNumber,
    ]

    let emailField: [String: Any] = [
        "key": "email",
        "label": "Email",
        "value": passObject.email,
    ]

    var secondaryFields: [Any] = []

    if passObject.name != "" {
        secondaryFields.append(nameField)
    }

    if passObject.title != "" {
        secondaryFields.append(titleField)
    }

    if passObject.businessName != "" {
        secondaryFields.append(businessNameField)
    }

    if passObject.phoneNumber != "" {
        secondaryFields.append(phoneNumberField)
    }

    if passObject.email != "" {
        secondaryFields.append(emailField)
    }

    let data: [String: Any] = [
        "primaryFields": [primaryFields],
        "secondaryFields": secondaryFields,
    ]

    let generic: [String: Any] = [
        "generic": data,
    ]
    return generic
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
