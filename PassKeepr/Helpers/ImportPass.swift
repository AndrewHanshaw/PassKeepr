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

    // Parse localized strings and build a resolver for the user's preferred language
    let allStrings = parseStringsFiles(from: archive)
    let resolver = buildResolver(from: allStrings)

    // Create a new PassObject
    var passObject = PassObject()

    // Extract basic metadata
    if let description = passJson["description"] as? String {
        passObject.description = resolveString(description, using: resolver)
    }

    // Extract colors
    passObject.foregroundColor = parseColor(passJson["foregroundColor"] as? String) ?? 0x000000
    passObject.backgroundColor = parseColor(passJson["backgroundColor"] as? String) ?? 0xFFFFFF
    passObject.labelColor = parseColor(passJson["labelColor"] as? String) ?? 0x000000

    // Determine pass style and extract fields
    if let storeCard = passJson["storeCard"] as? [String: Any] {
        extractFields(from: storeCard, into: &passObject, resolver: resolver)
    } else if let eventTicket = passJson["eventTicket"] as? [String: Any] {
        extractFields(from: eventTicket, into: &passObject, resolver: resolver)
    } else if let generic = passJson["generic"] as? [String: Any] {
        extractFields(from: generic, into: &passObject, resolver: resolver)
    } else if let boardingPass = passJson["boardingPass"] as? [String: Any] {
        extractFields(from: boardingPass, into: &passObject, resolver: resolver)
    } else if let coupon = passJson["coupon"] as? [String: Any] {
        extractFields(from: coupon, into: &passObject, resolver: resolver)
    }

    // Extract barcode
    if let barcode = passJson["barcode"] as? [String: Any] {
        extractBarcode(from: barcode, into: &passObject, resolver: resolver)
    } else if let barcodes = passJson["barcodes"] as? [[String: Any]],
              let firstBarcode = barcodes.first
    {
        extractBarcode(from: firstBarcode, into: &passObject, resolver: resolver)
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

    // Parse all *.lproj/pass.strings files from the archive.
    // Returns a dict mapping language code -> [key: value].
    func parseStringsFiles(from archive: Archive) -> [String: [String: String]] {
        var result: [String: [String: String]] = [:]
        for entry in archive {
            let path = entry.path
            guard path.hasSuffix(".lproj/pass.strings") else { continue }
            // Derive language code from folder name (e.g. "en.lproj/pass.strings" -> "en")
            let lang = String(path.prefix(while: { $0 != "." }))
            guard !lang.isEmpty,
                  let data = extractEntry(entry, from: archive),
                  let strings = try? PropertyListSerialization.propertyList(
                      from: data, options: [], format: nil
                  ) as? [String: String]
            else { continue }
            result[lang] = strings
            print("Loaded \(strings.count) localized strings for language: \(lang)")
        }
        return result
    }

    // Build a flat resolver for the user's preferred language, filling gaps from English.
    func buildResolver(from allStrings: [String: [String: String]]) -> [String: String] {
        guard !allStrings.isEmpty else { return [:] }
        let available = Array(allStrings.keys)
        let lang = preferredLanguage(from: available) ?? available[0]
        var resolved = allStrings["en"] ?? [:]
        if lang != "en", let preferred = allStrings[lang] {
            resolved.merge(preferred) { _, new in new }
        }
        print("Resolving localized strings using language: \(lang)")
        return resolved
    }

    // Return the first device-preferred language that is available in the pass. Fall back to "en" if present, then nil.
    func preferredLanguage(from available: [String]) -> String? {
        for preferred in Locale.preferredLanguages {
            let code = preferred.components(separatedBy: "-").first ?? preferred
            if available.contains(code) { return code }
        }
        return available.contains("en") ? "en" : nil
    }

    // Resolve a raw string that may be a localization key, returning it unchanged if not found.
    func resolveString(_ raw: String, using resolver: [String: String]) -> String {
        resolver[raw] ?? raw
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

    func extractFields(from passStyle: [String: Any], into passObject: inout PassObject, resolver: [String: String]) {
        // Convert a field value to a string, resolving localization keys for string values.
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
                return resolveString(stringValue, using: resolver)
            } else if let numberValue = finalValue as? NSNumber {
                return numberValue.stringValue
            } else if let doubleValue = finalValue as? Double {
                return String(doubleValue)
            } else if let intValue = finalValue as? Int {
                return String(intValue)
            }
            return String(describing: finalValue)
        }

        func resolveLabel(_ raw: String?) -> String {
            resolveString(raw ?? "", using: resolver)
        }

        // Extract header fields
        if let headerFields = passStyle["headerFields"] as? [[String: Any]] {
            if headerFields.count > 0 {
                passObject.headerFieldOneLabel = resolveLabel(headerFields[0]["label"] as? String)
                passObject.headerFieldOneText = valueToString(headerFields[0]["value"])
            }
            if headerFields.count > 1 {
                passObject.isHeaderFieldTwoOn = true
                passObject.headerFieldTwoLabel = resolveLabel(headerFields[1]["label"] as? String)
                passObject.headerFieldTwoText = valueToString(headerFields[1]["value"])
            }
        }

        // Extract primary fields
        if let primaryFields = passStyle["primaryFields"] as? [[String: Any]],
           let firstPrimary = primaryFields.first
        {
            passObject.primaryFieldLabel = resolveLabel(firstPrimary["label"] as? String)
            passObject.primaryFieldText = valueToString(firstPrimary["value"])
        }

        // Extract secondary fields
        if let secondaryFields = passStyle["secondaryFields"] as? [[String: Any]] {
            if secondaryFields.count > 0 {
                passObject.secondaryFieldOneLabel = resolveLabel(secondaryFields[0]["label"] as? String)
                passObject.secondaryFieldOneText = valueToString(secondaryFields[0]["value"])
            }
            if secondaryFields.count > 1 {
                passObject.isSecondaryFieldTwoOn = true
                passObject.secondaryFieldTwoLabel = resolveLabel(secondaryFields[1]["label"] as? String)
                passObject.secondaryFieldTwoText = valueToString(secondaryFields[1]["value"])
            }
            if secondaryFields.count > 2 {
                passObject.isSecondaryFieldThreeOn = true
                passObject.secondaryFieldThreeLabel = resolveLabel(secondaryFields[2]["label"] as? String)
                passObject.secondaryFieldThreeText = valueToString(secondaryFields[2]["value"])
            }
        }

        // Extract auxiliary fields
        if let auxiliaryFields = passStyle["auxiliaryFields"] as? [[String: Any]] {
            if auxiliaryFields.count > 0 {
                passObject.auxiliaryFieldOneLabel = resolveLabel(auxiliaryFields[0]["label"] as? String)
                passObject.auxiliaryFieldOneText = valueToString(auxiliaryFields[0]["value"])
            }
            if auxiliaryFields.count > 1 {
                passObject.isAuxiliaryFieldTwoOn = true
                passObject.auxiliaryFieldTwoLabel = resolveLabel(auxiliaryFields[1]["label"] as? String)
                passObject.auxiliaryFieldTwoText = valueToString(auxiliaryFields[1]["value"])
            }
            if auxiliaryFields.count > 2 {
                passObject.isAuxiliaryFieldThreeOn = true
                passObject.auxiliaryFieldThreeLabel = resolveLabel(auxiliaryFields[2]["label"] as? String)
                passObject.auxiliaryFieldThreeText = valueToString(auxiliaryFields[2]["value"])
            }
        }
    }

    func extractBarcode(from barcode: [String: Any], into passObject: inout PassObject, resolver: [String: String]) {
        // Extract barcode message
        if let message = barcode["message"] as? String {
            passObject.barcodeString = message
        }

        // Extract alt text
        if let altText = barcode["altText"] as? String {
            passObject.altText = resolveString(altText, using: resolver)
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
        func extractLargestVariant(_ baseName: String) -> Data {
            let x3 = archive["\(baseName)@3x.png"].flatMap { extractEntry($0, from: archive) } ?? Data()
            if x3 != Data() { return x3 }
            let x2 = archive["\(baseName)@2x.png"].flatMap { extractEntry($0, from: archive) } ?? Data()
            if x2 != Data() { return x2 }
            let standard = archive["\(baseName).png"].flatMap { extractEntry($0, from: archive) } ?? Data()
            return standard
        }

        // Extract icon (required)
        let icon = extractLargestVariant("icon")
        passObject.passIcon = icon

        // Extract logo
        let logo = extractLargestVariant("logo")
        if logo != Data() {
            passObject.logoImage = logo
            passObject.logoImageType = .photo
        }

        // Extract strip image
        let strip = extractLargestVariant("strip")
        if strip != Data() {
            passObject.stripImage = strip
            passObject.isCustomStripImageOn = true
        }

        // Extract background image
        let bg = extractLargestVariant("background")
        passObject.backgroundImage = bg

        // Extract thumbnail image
        let thumbnail = extractLargestVariant("thumbnail")
        if thumbnail != Data() {
            passObject.thumbnailImage = thumbnail
            passObject.thumbnailImageType = .photo
        }
    }
}
