import Foundation
import ZIPFoundation

/// Import a .pkpass file and convert it to a PassObject
/// Returns nil if the import fails
func importPass(from pkpassURL: URL) -> PassObject? {
    print("Starting import from: \(pkpassURL.path)")
    print("File exists: \(FileManager.default.fileExists(atPath: pkpassURL.path))")

    // Open the .pkpass file as a ZIP archive
    guard let archive = Archive(url: pkpassURL, accessMode: .read) else {
        print("Failed to open archive at: \(pkpassURL)")
        return nil
    }

    print("Archive opened successfully")

    // Extract pass.json
    guard let passJsonEntry = archive["pass.json"],
          let passJsonData = extractEntry(passJsonEntry, from: archive)
    else {
        print("Failed to extract pass.json")
        return nil
    }

    print("Extracted pass.json (\(passJsonData.count) bytes)")

    // Parse pass.json
    guard let passJson = try? JSONSerialization.jsonObject(with: passJsonData) as? [String: Any] else {
        print("Failed to parse pass.json")
        return nil
    }

    print("Parsed pass.json successfully")

    // Create a new PassObject
    var passObject = PassObject()

    // Extract basic metadata
    if let description = passJson["description"] as? String {
        passObject.description = description
    }

    // Extract colors
    passObject.foregroundColor = parseColor(passJson["foregroundColor"] as? String) ?? 0x000000
    passObject.backgroundColor = parseColor(passJson["backgroundColor"] as? String) ?? 0xFFFFFF
    passObject.labelColor = parseColor(passJson["labelColor"] as? String) ?? 0x000000

    // Determine pass style and extract fields
    if let storeCard = passJson["storeCard"] as? [String: Any] {
        extractFields(from: storeCard, into: &passObject)
    } else if let eventTicket = passJson["eventTicket"] as? [String: Any] {
        extractFields(from: eventTicket, into: &passObject)
    } else if let generic = passJson["generic"] as? [String: Any] {
        extractFields(from: generic, into: &passObject)
    } else if let boardingPass = passJson["boardingPass"] as? [String: Any] {
        extractFields(from: boardingPass, into: &passObject)
    } else if let coupon = passJson["coupon"] as? [String: Any] {
        extractFields(from: coupon, into: &passObject)
    }

    // Extract barcode
    if let barcode = passJson["barcode"] as? [String: Any] {
        extractBarcode(from: barcode, into: &passObject)
    } else if let barcodes = passJson["barcodes"] as? [[String: Any]],
              let firstBarcode = barcodes.first
    {
        extractBarcode(from: firstBarcode, into: &passObject)
    }

    // Extract images
    extractImages(from: archive, into: &passObject)

    return passObject

    func extractEntry(_ entry: Entry, from archive: Archive) -> Data? {
        var data = Data()
        do {
            _ = try archive.extract(entry) { chunk in
                data.append(chunk)
            }
            return data
        } catch {
            print("Error extracting entry \(entry.path): \(error)")
            return nil
        }
    }

    func parseColor(_ colorString: String?) -> UInt? {
        guard let colorString = colorString else { return nil }

        // PassKit colors are in format "rgb(r, g, b)" where r, g, b are 0-255
        let pattern = #"rgb\((\d+),\s*(\d+),\s*(\d+)\)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                  in: colorString, range: NSRange(colorString.startIndex..., in: colorString)
              )
        else {
            return nil
        }

        let r = (colorString as NSString).substring(with: match.range(at: 1))
        let g = (colorString as NSString).substring(with: match.range(at: 2))
        let b = (colorString as NSString).substring(with: match.range(at: 3))

        guard let red = UInt(r), let green = UInt(g), let blue = UInt(b) else {
            return nil
        }

        // Convert to hex: 0xRRGGBB
        return (red << 16) | (green << 8) | blue
    }

    func extractFields(from passStyle: [String: Any], into passObject: inout PassObject) {
        // Helper function to convert field values to strings
        func valueToString(_ value: Any?) -> String {
            // First unwrap the optional if it's an Optional<Any>
            var unwrappedValue: Any?
            let mirror = Mirror(reflecting: value as Any)
            if mirror.displayStyle == .optional {
                unwrappedValue = mirror.children.first?.value
            } else {
                unwrappedValue = value
            }

            guard let finalValue = unwrappedValue else {
                return ""
            }

            if let stringValue = finalValue as? String {
                return stringValue
            } else if let numberValue = finalValue as? NSNumber {
                return numberValue.stringValue
            } else if let doubleValue = finalValue as? Double {
                return String(doubleValue)
            } else if let intValue = finalValue as? Int {
                return String(intValue)
            }
            return String(describing: finalValue)
        }

        // Extract header fields
        if let headerFields = passStyle["headerFields"] as? [[String: Any]] {
            if headerFields.count > 0 {
                passObject.headerFieldOneLabel = headerFields[0]["label"] as? String ?? ""
                passObject.headerFieldOneText = valueToString(headerFields[0]["value"])
            }
            if headerFields.count > 1 {
                passObject.isHeaderFieldTwoOn = true
                passObject.headerFieldTwoLabel = headerFields[1]["label"] as? String ?? ""
                passObject.headerFieldTwoText = valueToString(headerFields[1]["value"])
            }
        }

        // Extract primary fields
        if let primaryFields = passStyle["primaryFields"] as? [[String: Any]],
           let firstPrimary = primaryFields.first
        {
            passObject.primaryFieldLabel = firstPrimary["label"] as? String ?? ""
            passObject.primaryFieldText = valueToString(firstPrimary["value"])
        }

        // Extract secondary fields
        if let secondaryFields = passStyle["secondaryFields"] as? [[String: Any]] {
            if secondaryFields.count > 0 {
                passObject.secondaryFieldOneLabel = secondaryFields[0]["label"] as? String ?? ""
                passObject.secondaryFieldOneText = valueToString(secondaryFields[0]["value"])
            }
            if secondaryFields.count > 1 {
                passObject.isSecondaryFieldTwoOn = true
                passObject.secondaryFieldTwoLabel = secondaryFields[1]["label"] as? String ?? ""
                passObject.secondaryFieldTwoText = valueToString(secondaryFields[1]["value"])
            }
            if secondaryFields.count > 2 {
                passObject.isSecondaryFieldThreeOn = true
                passObject.secondaryFieldThreeLabel = secondaryFields[2]["label"] as? String ?? ""
                passObject.secondaryFieldThreeText = valueToString(secondaryFields[2]["value"])
            }
        }
    }

    func extractBarcode(from barcode: [String: Any], into passObject: inout PassObject) {
        // Extract barcode message
        if let message = barcode["message"] as? String {
            passObject.barcodeString = message
        }

        // Extract alt text
        if let altText = barcode["altText"] as? String {
            passObject.altText = altText
        }

        // Map PassKit barcode format to BarcodeType
        if let format = barcode["format"] as? String {
            switch format {
            case "PKBarcodeFormatQR":
                passObject.barcodeType = .qr
            case "PKBarcodeFormatPDF417":
                passObject.barcodeType = .pdf417
            case "PKBarcodeFormatAztec":
                // PassKeepr doesn't support Aztec, default to QR
                passObject.barcodeType = .qr
            case "PKBarcodeFormatCode128":
                passObject.barcodeType = .code128
            default:
                passObject.barcodeType = .none
            }
        }
    }

    func extractImages(from archive: Archive, into passObject: inout PassObject) {
        // Try to extract icon (required)
        if let iconEntry = archive["icon@3x.png"] ?? archive["icon@2x.png"] ?? archive["icon.png"],
           let iconData = extractEntry(iconEntry, from: archive)
        {
            passObject.passIcon = iconData
        }

        // Try to extract logo
        if let logoEntry = archive["logo@3x.png"] ?? archive["logo@2x.png"] ?? archive["logo.png"],
           let logoData = extractEntry(logoEntry, from: archive)
        {
            passObject.logoImage = logoData
            passObject.logoImageType = .photo
        }

        // Try to extract strip image
        if let stripEntry = archive["strip@3x.png"] ?? archive["strip@2x.png"]
            ?? archive["strip.png"],
            let stripData = extractEntry(stripEntry, from: archive)
        {
            passObject.stripImage = stripData
            passObject.isCustomStripImageOn = true
        }

        // Try to extract background image
        if let bgEntry = archive["background@3x.png"] ?? archive["background@2x.png"]
            ?? archive["background.png"],
            let bgData = extractEntry(bgEntry, from: archive)
        {
            passObject.backgroundImage = bgData
        }
    }
}
