import CoreGraphics
import Foundation
import ZIPFoundation

// Helper: save 1x and optional @2x/@3x variants from PassObject image
func saveImageVariants(from data: Data, name: String, passDirectory: URL, maxWidth: CGFloat, maxHeight: CGFloat) {
    guard let cgImage = ImageIOHelpers.decode(data) else {
        // Not a decodable image - write raw data
        savePNGToDirectory(pngData: data, destinationDirectory: passDirectory, fileName: name)
        return
    }

    let srcPixelW = CGFloat(cgImage.width)
    let srcPixelH = CGFloat(cgImage.height)

    // Debug: initial sizes
    print("[saveImageVariants] name=\(name) srcPixels=\(Int(srcPixelW))x\(Int(srcPixelH))")

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
        if let resized = ImageIOHelpers.resizedPNGData(from: cgImage, width: targetW, height: targetH) {
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
        } else if let png3 = ImageIOHelpers.resizedPNGData(from: cgImage, width: final3xW, height: final3xH) {
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

public let signNonceUserInfoKey = "signNonce"

// Initializes a new PassKit pass for the given pass
public func generatePass(passObject: PassObject, directory: URL = URL.applicationSupportDirectory) -> URL? {
    let fileManager = FileManager.default
    let passDirectory = directory.appending(path: "\(passObject.id.uuidString).pass")

    do {
        // Create the directory for the pass
        try fileManager.createDirectory(at: passDirectory, withIntermediateDirectories: true)

        // Add a pass.json to it
        let fileURL = passDirectory.appendingPathComponent("pass.json")
        fileManager.createFile(atPath: fileURL.path, contents: Data())

        // Add the pass.json contents provided by the model layer
        var passJSON = passObject.passJSONDictionary
        // Unique per generated pass so we can tell whether Wallet holds this exact version (vs. an older one with the same serial number)
        passJSON["userInfo"] = [signNonceUserInfoKey: UUID().uuidString]
        let jsonData = try JSONSerialization.data(withJSONObject: passJSON, options: .prettyPrinted)
        try jsonData.write(to: fileURL)

        // The model layer decides which images the package will actually contain
        let includeBackgroundImage = passObject.shouldIncludeBackgroundImage
        let includeStripImage = passObject.shouldIncludeStripImage

        saveImageVariants(from: passObject.passIcon, name: "icon", passDirectory: passDirectory, maxWidth: PassKitConstants.IconImage.width, maxHeight: PassKitConstants.IconImage.height)

        if includeStripImage {
            if passObject.passStyleKey != "storeCard" {
                print("PassObject has stripImage but is not of style 'storeCard'")
            }

            if passObject.backgroundImage != Data(), passObject.isBackgroundImageOn {
                print("PassObject has background image and strip image. Not saving strip image")
            } else {
                saveSingleScaleImage(from: passObject.stripImage, name: "strip", passDirectory: passDirectory, maxWidth: PassKitConstants.StripImage.width, maxHeight: PassKitConstants.StripImage.height)
            }
        }

        if includeBackgroundImage {
            if passObject.passStyleKey != "eventTicket" {
                print("PassObject should have background image but is not of style 'eventTicket'")
            }
            saveSingleScaleImage(from: passObject.backgroundImage, name: "background", passDirectory: passDirectory, maxWidth: PassKitConstants.BackgroundImage.width, maxHeight: PassKitConstants.BackgroundImage.height)
        }

        if passObject.logoImage != Data() {
            saveImageVariants(from: passObject.logoImage, name: "logo", passDirectory: passDirectory, maxWidth: PassKitConstants.LogoImage.width, maxHeight: PassKitConstants.LogoImage.height)
        }

        // The pass thumbnail image should only be included for generic and eventTicket passes, and only if the custom strip image toggle is off (because in the preview display that we render, the strip image placeholder is shown even if the strip image doesn't containa any data)
        // For passes with actual strip image data (barcode or custom), the pass will be storeCard, so the generic/eventTicket check will kick out of this conditional
        if passObject.thumbnailImage != Data(), passObject.passStyleKey == "generic" || passObject.passStyleKey == "eventTicket", !passObject.isCustomStripImageOn {
            saveImageVariants(from: passObject.thumbnailImage, name: "thumbnail", passDirectory: passDirectory, maxWidth: PassKitConstants.ThumbnailImage.width, maxHeight: PassKitConstants.ThumbnailImage.height)
        }

        if let pkpassDir = try zipDirectory(uuid: passObject.id, directory: directory) {
            return pkpassDir
        } else {
            return nil
        }

    } catch {
        return nil
    }
}

func zipDirectory(uuid: UUID, directory: URL = URL.applicationSupportDirectory) throws -> URL? {
    let fileManager = FileManager()
    let passDirectory = directory.appending(path: "\(uuid.uuidString).pass")
    let pkpassDirectory = directory.appending(path: "\(uuid.uuidString).pkpass")

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
// Separators are interpreted using the given locale, so "1,50" is 1.5 in a comma-decimal locale (e.g. de_DE)
// while "1,500" is 1500 in en_US.
public func currencyFieldValue(_ text: String, locale: Locale = .current) -> Double {
    let decimalSeparator = locale.decimalSeparator ?? "."
    let groupingSeparator = locale.groupingSeparator ?? ","

    var cleaned = text
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .filter { $0.isNumber || $0 == "-" || String($0) == decimalSeparator || String($0) == groupingSeparator }

    // Drop grouping separators first, then normalize the locale's decimal separator to "." for Double parsing.
    if groupingSeparator != decimalSeparator {
        cleaned = cleaned.replacingOccurrences(of: groupingSeparator, with: "")
    }
    cleaned = cleaned.replacingOccurrences(of: decimalSeparator, with: ".")

    return Double(cleaned) ?? 0
}

// Saves an image as a single 1x PNG, downscaling to fit within the given max dimensions if necessary
func saveSingleScaleImage(from data: Data, name: String, passDirectory: URL, maxWidth: CGFloat, maxHeight: CGFloat) {
    guard let cgImage = ImageIOHelpers.decode(data) else {
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
        if let resized = ImageIOHelpers.resizedPNGData(from: cgImage, width: targetW, height: targetH) {
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
