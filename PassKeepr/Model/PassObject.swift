import Foundation
import SwiftUI

struct PassObject: Codable, Identifiable, Equatable, Hashable, Transferable {
    static let defaultDescription: String = "PassKeepr Pass"
    var id: UUID
    var group: Int
    var passIcon: Data
    var passIconType: ImageType
    var barcodeString: String
    var barcodeType: BarcodeType
    var barcodeBorder: Double
    var stripImage: Data // PNG data for all passes that use the strip image (may be a barcode, picture, etc)
    var backgroundImage: Data // PNG data for all passes that use the background image
    // Cached brightness classification of `backgroundImage`, computed once whenever the image is set
    // (see `updateBackgroundImage`) rather than every time a card is rendered. `nil` means there's no
    // background image, in which case `backgroundBrightness` falls back to `backgroundColor`.
    var imageBackgroundBrightness: BackgroundBrightness? = nil
    var logoImage: Data // PNG data for all passes that use the logo image
    var logoImageType: ImageType
    var thumbnailImage: Data // PNG data for thumbnail image (90x90 points, aspect ratio 2:3 to 3:2)
    var thumbnailImageType: ImageType
    var qrCodeCorrectionLevel: QrCodeCorrectionLevel
    var qrCodeEncoding: QrCodeEncoding
    var qrCodeType: QrCodeType
    var altText: String
    var foregroundColor: UInt
    var backgroundColor: UInt
    var labelColor: UInt
    var description: String
    var headerFieldOneLabel: String
    var headerFieldOneText: String
    var isHeaderFieldTwoOn: Bool
    var headerFieldTwoLabel: String
    var headerFieldTwoText: String
    /* Technically, PassKit supports a third header field, but the space available is so tight that a third one is effectively useless. Maybe this will change later */
    var primaryFieldLabel: String
    var primaryFieldText: String
    var secondaryFieldOneLabel: String
    var secondaryFieldOneText: String
    var isSecondaryFieldTwoOn: Bool
    var secondaryFieldTwoLabel: String
    var secondaryFieldTwoText: String
    var isSecondaryFieldThreeOn: Bool
    var secondaryFieldThreeLabel: String
    var secondaryFieldThreeText: String
    var isAuxiliaryFieldOneOn: Bool
    var auxiliaryFieldOneLabel: String
    var auxiliaryFieldOneText: String
    var isAuxiliaryFieldTwoOn: Bool
    var auxiliaryFieldTwoLabel: String
    var auxiliaryFieldTwoText: String
    var isAuxiliaryFieldThreeOn: Bool
    var auxiliaryFieldThreeLabel: String
    var auxiliaryFieldThreeText: String
    var isCustomStripImageOn: Bool
    var logoSymbolName: String
    var logoSymbolColor: UInt
    var thumbnailSymbolName: String
    var thumbnailSymbolColor: UInt
    var passIconSymbolName: String
    var passIconSymbolColor: UInt
    var passIconBackgroundColor: UInt
    var associatedStoreIdentifiers: [Int]
    // WiFi QR Code
    var wifiSSID: String
    var wifiPassword: String
    var wifiSecurity: WifiSecurity
    var wifiIsHidden: Bool
    // vCard QR Code
    var vcardFirstName: String
    var vcardLastName: String
    var vcardCompany: String
    var vcardPhone: String
    var vcardEmail: String
    var vcardURL: String
    var vcardAddress: String
    var vcardSocial: String
    var vcardHasBirthday: Bool
    var vcardBirthday: Date
    var vcardCustomFields: [VCardCustomField]
    var hasExpirationDate: Bool
    var expirationDate: Date
    var locations: [PassLocation]
    var isCurrencyFieldsOn: Bool
    var currencyCode: String
    var isPrimaryFieldCurrency: Bool
    var isHeaderFieldOneCurrency: Bool
    var isHeaderFieldTwoCurrency: Bool
    var isSecondaryFieldOneCurrency: Bool
    var isSecondaryFieldTwoCurrency: Bool
    var isSecondaryFieldThreeCurrency: Bool
    var isAuxiliaryFieldOneCurrency: Bool
    var isAuxiliaryFieldTwoCurrency: Bool
    var isAuxiliaryFieldThreeCurrency: Bool

    enum CodingKeys: String, CodingKey {
        case id, group, passIcon, passIconType, barcodeString, barcodeType, barcodeBorder
        case stripImage, backgroundImage, imageBackgroundBrightness, logoImage, logoImageType
        case thumbnailImage, thumbnailImageType
        case qrCodeCorrectionLevel, qrCodeEncoding, qrCodeType
        case altText, foregroundColor, backgroundColor, labelColor, description
        case headerFieldOneLabel, headerFieldOneText, isHeaderFieldTwoOn, headerFieldTwoLabel, headerFieldTwoText
        case primaryFieldLabel, primaryFieldText
        case secondaryFieldOneLabel, secondaryFieldOneText
        case isSecondaryFieldTwoOn, secondaryFieldTwoLabel, secondaryFieldTwoText
        case isSecondaryFieldThreeOn, secondaryFieldThreeLabel, secondaryFieldThreeText
        case isAuxiliaryFieldOneOn, auxiliaryFieldOneLabel, auxiliaryFieldOneText
        case isAuxiliaryFieldTwoOn, auxiliaryFieldTwoLabel, auxiliaryFieldTwoText
        case isAuxiliaryFieldThreeOn, auxiliaryFieldThreeLabel, auxiliaryFieldThreeText
        case isCustomStripImageOn
        case logoSymbolName, logoSymbolColor
        case thumbnailSymbolName, thumbnailSymbolColor
        case passIconSymbolName, passIconSymbolColor, passIconBackgroundColor
        case associatedStoreIdentifiers
        case wifiSSID, wifiPassword, wifiSecurity, wifiIsHidden
        case vcardFirstName, vcardLastName, vcardCompany, vcardPhone, vcardEmail
        case vcardURL, vcardAddress, vcardSocial, vcardHasBirthday, vcardBirthday, vcardCustomFields
        case hasExpirationDate, expirationDate
        case locations
        case isCurrencyFieldsOn, currencyCode
        case isPrimaryFieldCurrency
        case isHeaderFieldOneCurrency, isHeaderFieldTwoCurrency
        case isSecondaryFieldOneCurrency, isSecondaryFieldTwoCurrency, isSecondaryFieldThreeCurrency
        case isAuxiliaryFieldOneCurrency, isAuxiliaryFieldTwoCurrency, isAuxiliaryFieldThreeCurrency
    }

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .data)
    }
}

extension PassObject {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let defaultIcon = (try? Data(contentsOf: Bundle.main.url(forResource: "DefaultPassIcon", withExtension: "png") ?? URL(fileURLWithPath: ""))) ?? Data()

        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        group = try c.decodeIfPresent(Int.self, forKey: .group) ?? 1
        passIcon = try c.decodeIfPresent(Data.self, forKey: .passIcon) ?? defaultIcon
        passIconType = try c.decodeIfPresent(ImageType.self, forKey: .passIconType) ?? .photo
        barcodeString = try c.decodeIfPresent(String.self, forKey: .barcodeString) ?? ""
        barcodeType = try c.decodeIfPresent(BarcodeType.self, forKey: .barcodeType) ?? .none
        barcodeBorder = try c.decodeIfPresent(Double.self, forKey: .barcodeBorder) ?? 0
        stripImage = try c.decodeIfPresent(Data.self, forKey: .stripImage) ?? Data()
        backgroundImage = try c.decodeIfPresent(Data.self, forKey: .backgroundImage) ?? Data()
        imageBackgroundBrightness = try c.decodeIfPresent(BackgroundBrightness.self, forKey: .imageBackgroundBrightness)
        logoImage = try c.decodeIfPresent(Data.self, forKey: .logoImage) ?? Data()
        logoImageType = try c.decodeIfPresent(ImageType.self, forKey: .logoImageType) ?? .none
        thumbnailImage = try c.decodeIfPresent(Data.self, forKey: .thumbnailImage) ?? Data()
        thumbnailImageType = try c.decodeIfPresent(ImageType.self, forKey: .thumbnailImageType) ?? .none
        qrCodeCorrectionLevel = try c.decodeIfPresent(QrCodeCorrectionLevel.self, forKey: .qrCodeCorrectionLevel) ?? .medium
        qrCodeEncoding = try c.decodeIfPresent(QrCodeEncoding.self, forKey: .qrCodeEncoding) ?? .ascii
        qrCodeType = try c.decodeIfPresent(QrCodeType.self, forKey: .qrCodeType) ?? .standard
        altText = try c.decodeIfPresent(String.self, forKey: .altText) ?? ""
        foregroundColor = try c.decodeIfPresent(UInt.self, forKey: .foregroundColor) ?? 0x000000
        backgroundColor = try c.decodeIfPresent(UInt.self, forKey: .backgroundColor) ?? 0xFFFFFF
        labelColor = try c.decodeIfPresent(UInt.self, forKey: .labelColor) ?? 0x000000
        description = try c.decodeIfPresent(String.self, forKey: .description) ?? PassObject.defaultDescription
        headerFieldOneLabel = try c.decodeIfPresent(String.self, forKey: .headerFieldOneLabel) ?? ""
        headerFieldOneText = try c.decodeIfPresent(String.self, forKey: .headerFieldOneText) ?? ""
        isHeaderFieldTwoOn = try c.decodeIfPresent(Bool.self, forKey: .isHeaderFieldTwoOn) ?? false
        headerFieldTwoLabel = try c.decodeIfPresent(String.self, forKey: .headerFieldTwoLabel) ?? ""
        headerFieldTwoText = try c.decodeIfPresent(String.self, forKey: .headerFieldTwoText) ?? ""
        primaryFieldLabel = try c.decodeIfPresent(String.self, forKey: .primaryFieldLabel) ?? ""
        primaryFieldText = try c.decodeIfPresent(String.self, forKey: .primaryFieldText) ?? ""
        secondaryFieldOneLabel = try c.decodeIfPresent(String.self, forKey: .secondaryFieldOneLabel) ?? ""
        secondaryFieldOneText = try c.decodeIfPresent(String.self, forKey: .secondaryFieldOneText) ?? ""
        isSecondaryFieldTwoOn = try c.decodeIfPresent(Bool.self, forKey: .isSecondaryFieldTwoOn) ?? false
        secondaryFieldTwoLabel = try c.decodeIfPresent(String.self, forKey: .secondaryFieldTwoLabel) ?? ""
        secondaryFieldTwoText = try c.decodeIfPresent(String.self, forKey: .secondaryFieldTwoText) ?? ""
        isSecondaryFieldThreeOn = try c.decodeIfPresent(Bool.self, forKey: .isSecondaryFieldThreeOn) ?? false
        secondaryFieldThreeLabel = try c.decodeIfPresent(String.self, forKey: .secondaryFieldThreeLabel) ?? ""
        secondaryFieldThreeText = try c.decodeIfPresent(String.self, forKey: .secondaryFieldThreeText) ?? ""
        isAuxiliaryFieldOneOn = try c.decodeIfPresent(Bool.self, forKey: .isAuxiliaryFieldOneOn) ?? true
        auxiliaryFieldOneLabel = try c.decodeIfPresent(String.self, forKey: .auxiliaryFieldOneLabel) ?? ""
        auxiliaryFieldOneText = try c.decodeIfPresent(String.self, forKey: .auxiliaryFieldOneText) ?? ""
        isAuxiliaryFieldTwoOn = try c.decodeIfPresent(Bool.self, forKey: .isAuxiliaryFieldTwoOn) ?? false
        auxiliaryFieldTwoLabel = try c.decodeIfPresent(String.self, forKey: .auxiliaryFieldTwoLabel) ?? ""
        auxiliaryFieldTwoText = try c.decodeIfPresent(String.self, forKey: .auxiliaryFieldTwoText) ?? ""
        isAuxiliaryFieldThreeOn = try c.decodeIfPresent(Bool.self, forKey: .isAuxiliaryFieldThreeOn) ?? false
        auxiliaryFieldThreeLabel = try c.decodeIfPresent(String.self, forKey: .auxiliaryFieldThreeLabel) ?? ""
        auxiliaryFieldThreeText = try c.decodeIfPresent(String.self, forKey: .auxiliaryFieldThreeText) ?? ""
        isCustomStripImageOn = try c.decodeIfPresent(Bool.self, forKey: .isCustomStripImageOn) ?? false
        logoSymbolName = try c.decodeIfPresent(String.self, forKey: .logoSymbolName) ?? ""
        logoSymbolColor = try c.decodeIfPresent(UInt.self, forKey: .logoSymbolColor) ?? 0x000000
        thumbnailSymbolName = try c.decodeIfPresent(String.self, forKey: .thumbnailSymbolName) ?? ""
        thumbnailSymbolColor = try c.decodeIfPresent(UInt.self, forKey: .thumbnailSymbolColor) ?? 0x000000
        passIconSymbolName = try c.decodeIfPresent(String.self, forKey: .passIconSymbolName) ?? ""
        passIconSymbolColor = try c.decodeIfPresent(UInt.self, forKey: .passIconSymbolColor) ?? 0x000000
        passIconBackgroundColor = try c.decodeIfPresent(UInt.self, forKey: .passIconBackgroundColor) ?? 0xFFFFFF
        associatedStoreIdentifiers = try c.decodeIfPresent([Int].self, forKey: .associatedStoreIdentifiers) ?? [6_740_440_736]
        wifiSSID = try c.decodeIfPresent(String.self, forKey: .wifiSSID) ?? ""
        wifiPassword = try c.decodeIfPresent(String.self, forKey: .wifiPassword) ?? ""
        wifiSecurity = try c.decodeIfPresent(WifiSecurity.self, forKey: .wifiSecurity) ?? .wpa
        wifiIsHidden = try c.decodeIfPresent(Bool.self, forKey: .wifiIsHidden) ?? false
        vcardFirstName = try c.decodeIfPresent(String.self, forKey: .vcardFirstName) ?? ""
        vcardLastName = try c.decodeIfPresent(String.self, forKey: .vcardLastName) ?? ""
        vcardCompany = try c.decodeIfPresent(String.self, forKey: .vcardCompany) ?? ""
        vcardPhone = try c.decodeIfPresent(String.self, forKey: .vcardPhone) ?? ""
        vcardEmail = try c.decodeIfPresent(String.self, forKey: .vcardEmail) ?? ""
        vcardURL = try c.decodeIfPresent(String.self, forKey: .vcardURL) ?? ""
        vcardAddress = try c.decodeIfPresent(String.self, forKey: .vcardAddress) ?? ""
        vcardSocial = try c.decodeIfPresent(String.self, forKey: .vcardSocial) ?? ""
        vcardHasBirthday = try c.decodeIfPresent(Bool.self, forKey: .vcardHasBirthday) ?? false
        vcardBirthday = try c.decodeIfPresent(Date.self, forKey: .vcardBirthday) ?? Date()
        vcardCustomFields = try c.decodeIfPresent([VCardCustomField].self, forKey: .vcardCustomFields) ?? []
        hasExpirationDate = try c.decodeIfPresent(Bool.self, forKey: .hasExpirationDate) ?? false
        expirationDate = try c.decodeIfPresent(Date.self, forKey: .expirationDate) ?? Date()
        locations = try c.decodeIfPresent([PassLocation].self, forKey: .locations) ?? []
        isCurrencyFieldsOn = try c.decodeIfPresent(Bool.self, forKey: .isCurrencyFieldsOn) ?? false
        currencyCode = try c.decodeIfPresent(String.self, forKey: .currencyCode) ?? "USD"
        isPrimaryFieldCurrency = try c.decodeIfPresent(Bool.self, forKey: .isPrimaryFieldCurrency) ?? false
        isHeaderFieldOneCurrency = try c.decodeIfPresent(Bool.self, forKey: .isHeaderFieldOneCurrency) ?? false
        isHeaderFieldTwoCurrency = try c.decodeIfPresent(Bool.self, forKey: .isHeaderFieldTwoCurrency) ?? false
        isSecondaryFieldOneCurrency = try c.decodeIfPresent(Bool.self, forKey: .isSecondaryFieldOneCurrency) ?? false
        isSecondaryFieldTwoCurrency = try c.decodeIfPresent(Bool.self, forKey: .isSecondaryFieldTwoCurrency) ?? false
        isSecondaryFieldThreeCurrency = try c.decodeIfPresent(Bool.self, forKey: .isSecondaryFieldThreeCurrency) ?? false
        isAuxiliaryFieldOneCurrency = try c.decodeIfPresent(Bool.self, forKey: .isAuxiliaryFieldOneCurrency) ?? false
        isAuxiliaryFieldTwoCurrency = try c.decodeIfPresent(Bool.self, forKey: .isAuxiliaryFieldTwoCurrency) ?? false
        isAuxiliaryFieldThreeCurrency = try c.decodeIfPresent(Bool.self, forKey: .isAuxiliaryFieldThreeCurrency) ?? false

        // Migration: passes saved before `imageBackgroundBrightness` existed won't have it persisted.
        // Compute it once here so older saved passes with a background image get correct contrast
        // immediately, instead of waiting until the user next edits the background.
        if imageBackgroundBrightness == nil, backgroundImage != Data() {
            imageBackgroundBrightness = Self.computeImageBrightness(from: backgroundImage)
        }
    }
}

extension PassObject {
    /// The brightness bucket used to keep card chrome (shadows, strokes, text overlays) legible
    /// against whatever is actually behind the card: the background image if there is one,
    /// otherwise the background color. Cheap to read in both cases — the image case is
    /// precomputed by `updateBackgroundImage` instead of being recalculated on every access.
    var backgroundBrightness: BackgroundBrightness {
        if let imageBackgroundBrightness {
            return imageBackgroundBrightness
        }

        let red = CGFloat((backgroundColor >> 16) & 0xFF) / 255.0
        let green = CGFloat((backgroundColor >> 8) & 0xFF) / 255.0
        let blue = CGFloat(backgroundColor & 0xFF) / 255.0
        return BackgroundBrightness(brightness: (0.299 * red) + (0.587 * green) + (0.114 * blue))
    }

    /// Sets `backgroundImage` and recomputes `imageBackgroundBrightness` to match. This is the
    /// only supported way to change `backgroundImage` — use this instead of assigning the
    /// property directly so brightness never goes stale.
    mutating func updateBackgroundImage(_ data: Data) {
        backgroundImage = data
        imageBackgroundBrightness = Self.computeImageBrightness(from: data)
    }

    static func computeImageBrightness(from data: Data) -> BackgroundBrightness? {
        guard data != Data(), let image = UIImage(data: data) else { return nil }
        let brightness = image.resizeToFit(maxWidth: 40, maxHeight: 40).averageBrightness() ?? 0.5
        return BackgroundBrightness(brightness: brightness)
    }
}

extension PassObject {
    init() {
        let defaultIcon = (try? Data(contentsOf: Bundle.main.url(forResource: "DefaultPassIcon", withExtension: "png") ?? URL(fileURLWithPath: ""))) ?? Data()

        self.init(
            id: UUID(),
            group: 1,
            passIcon: defaultIcon,
            passIconType: .photo,
            barcodeString: "",
            barcodeType: .none,
            barcodeBorder: 0,
            stripImage: Data(),
            backgroundImage: Data(),
            logoImage: Data(),
            logoImageType: .none,
            thumbnailImage: Data(),
            thumbnailImageType: .none,
            qrCodeCorrectionLevel: .medium,
            qrCodeEncoding: .ascii,
            qrCodeType: .standard,
            altText: "",
            foregroundColor: 0x000000,
            backgroundColor: 0xFFFFFF,
            labelColor: 0x000000,
            description: PassObject.defaultDescription,
            headerFieldOneLabel: "",
            headerFieldOneText: "",
            isHeaderFieldTwoOn: false,
            headerFieldTwoLabel: "",
            headerFieldTwoText: "",
            primaryFieldLabel: "",
            primaryFieldText: "",
            secondaryFieldOneLabel: "",
            secondaryFieldOneText: "",
            isSecondaryFieldTwoOn: false,
            secondaryFieldTwoLabel: "",
            secondaryFieldTwoText: "",
            isSecondaryFieldThreeOn: false,
            secondaryFieldThreeLabel: "",
            secondaryFieldThreeText: "",
            isAuxiliaryFieldOneOn: true, // Default to on. This only needs to be toggled to not cramp the view when the strip image is on (which makes the aux fields share a line with the secondary fields)
            auxiliaryFieldOneLabel: "",
            auxiliaryFieldOneText: "",
            isAuxiliaryFieldTwoOn: false,
            auxiliaryFieldTwoLabel: "",
            auxiliaryFieldTwoText: "",
            isAuxiliaryFieldThreeOn: false,
            auxiliaryFieldThreeLabel: "",
            auxiliaryFieldThreeText: "",
            isCustomStripImageOn: false,
            logoSymbolName: "",
            logoSymbolColor: 0x000000,
            thumbnailSymbolName: "",
            thumbnailSymbolColor: 0x000000,
            passIconSymbolName: "",
            passIconSymbolColor: 0x000000,
            passIconBackgroundColor: 0xFFFFFF,
            associatedStoreIdentifiers: [6_740_440_736],
            wifiSSID: "",
            wifiPassword: "",
            wifiSecurity: .wpa,
            wifiIsHidden: false,
            vcardFirstName: "",
            vcardLastName: "",
            vcardCompany: "",
            vcardPhone: "",
            vcardEmail: "",
            vcardURL: "",
            vcardAddress: "",
            vcardSocial: "",
            vcardHasBirthday: false,
            vcardBirthday: Date(),
            vcardCustomFields: [],
            hasExpirationDate: false,
            expirationDate: Date(),
            locations: [],
            isCurrencyFieldsOn: false,
            currencyCode: "USD",
            isPrimaryFieldCurrency: false,
            isHeaderFieldOneCurrency: false,
            isHeaderFieldTwoCurrency: false,
            isSecondaryFieldOneCurrency: false,
            isSecondaryFieldTwoCurrency: false,
            isSecondaryFieldThreeCurrency: false,
            isAuxiliaryFieldOneCurrency: false,
            isAuxiliaryFieldTwoCurrency: false,
            isAuxiliaryFieldThreeCurrency: false
        )
    }

    func duplicate() -> PassObject {
        PassObject(
            id: UUID(),
            group: 1,
            passIcon: passIcon,
            passIconType: passIconType,
            barcodeString: barcodeString,
            barcodeType: barcodeType,
            barcodeBorder: barcodeBorder,
            stripImage: stripImage,
            backgroundImage: backgroundImage,
            imageBackgroundBrightness: imageBackgroundBrightness,
            logoImage: logoImage,
            logoImageType: logoImageType,
            thumbnailImage: thumbnailImage,
            thumbnailImageType: thumbnailImageType,
            qrCodeCorrectionLevel: qrCodeCorrectionLevel,
            qrCodeEncoding: qrCodeEncoding,
            qrCodeType: qrCodeType,
            altText: altText,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            labelColor: labelColor,
            description: description,
            headerFieldOneLabel: headerFieldOneLabel,
            headerFieldOneText: headerFieldOneText,
            isHeaderFieldTwoOn: isHeaderFieldTwoOn,
            headerFieldTwoLabel: headerFieldTwoLabel,
            headerFieldTwoText: headerFieldTwoText,
            primaryFieldLabel: primaryFieldLabel,
            primaryFieldText: primaryFieldText,
            secondaryFieldOneLabel: secondaryFieldOneLabel,
            secondaryFieldOneText: secondaryFieldOneText,
            isSecondaryFieldTwoOn: isSecondaryFieldTwoOn,
            secondaryFieldTwoLabel: secondaryFieldTwoLabel,
            secondaryFieldTwoText: secondaryFieldTwoText,
            isSecondaryFieldThreeOn: isSecondaryFieldThreeOn,
            secondaryFieldThreeLabel: secondaryFieldThreeLabel,
            secondaryFieldThreeText: secondaryFieldThreeText,
            isAuxiliaryFieldOneOn: isAuxiliaryFieldOneOn,
            auxiliaryFieldOneLabel: auxiliaryFieldOneLabel,
            auxiliaryFieldOneText: auxiliaryFieldOneText,
            isAuxiliaryFieldTwoOn: isAuxiliaryFieldTwoOn,
            auxiliaryFieldTwoLabel: auxiliaryFieldTwoLabel,
            auxiliaryFieldTwoText: auxiliaryFieldTwoText,
            isAuxiliaryFieldThreeOn: isAuxiliaryFieldThreeOn,
            auxiliaryFieldThreeLabel: auxiliaryFieldThreeLabel,
            auxiliaryFieldThreeText: auxiliaryFieldThreeText,
            isCustomStripImageOn: isCustomStripImageOn,
            logoSymbolName: logoSymbolName,
            logoSymbolColor: logoSymbolColor,
            thumbnailSymbolName: thumbnailSymbolName,
            thumbnailSymbolColor: thumbnailSymbolColor,
            passIconSymbolName: passIconSymbolName,
            passIconSymbolColor: passIconSymbolColor,
            passIconBackgroundColor: passIconBackgroundColor,
            associatedStoreIdentifiers: associatedStoreIdentifiers,
            wifiSSID: wifiSSID,
            wifiPassword: wifiPassword,
            wifiSecurity: wifiSecurity,
            wifiIsHidden: wifiIsHidden,
            vcardFirstName: vcardFirstName,
            vcardLastName: vcardLastName,
            vcardCompany: vcardCompany,
            vcardPhone: vcardPhone,
            vcardEmail: vcardEmail,
            vcardURL: vcardURL,
            vcardAddress: vcardAddress,
            vcardSocial: vcardSocial,
            vcardHasBirthday: vcardHasBirthday,
            vcardBirthday: vcardBirthday,
            vcardCustomFields: vcardCustomFields,
            hasExpirationDate: hasExpirationDate,
            expirationDate: expirationDate,
            locations: locations,
            isCurrencyFieldsOn: isCurrencyFieldsOn,
            currencyCode: currencyCode,
            isPrimaryFieldCurrency: isPrimaryFieldCurrency,
            isHeaderFieldOneCurrency: isHeaderFieldOneCurrency,
            isHeaderFieldTwoCurrency: isHeaderFieldTwoCurrency,
            isSecondaryFieldOneCurrency: isSecondaryFieldOneCurrency,
            isSecondaryFieldTwoCurrency: isSecondaryFieldTwoCurrency,
            isSecondaryFieldThreeCurrency: isSecondaryFieldThreeCurrency,
            isAuxiliaryFieldOneCurrency: isAuxiliaryFieldOneCurrency,
            isAuxiliaryFieldTwoCurrency: isAuxiliaryFieldTwoCurrency,
            isAuxiliaryFieldThreeCurrency: isAuxiliaryFieldThreeCurrency
        )
    }
}

enum QrCodeCorrectionLevel: Codable, CustomStringConvertible, CaseIterable {
    case low
    case medium
    case quartile
    case high

    var description: String {
        switch self {
        case .low: return "L"
        case .medium: return "M"
        case .quartile: return "Q"
        case .high: return "H"
        }
    }
}

enum QrCodeEncoding: Codable, CustomStringConvertible, CaseIterable {
    case ascii
    case utf8
    case unicode

    func toStringEncoding() -> String.Encoding {
        switch self {
        case .ascii: return .ascii
        case .utf8: return .utf8
        case .unicode: return .unicode
        }
    }

    var ianaEncodingName: String {
        switch self {
        case .ascii: return "us-ascii"
        case .utf8: return "utf-8"
        case .unicode: return "utf-16"
        }
    }

    func isCompatible(with string: String) -> Bool {
        string.data(using: toStringEncoding()) != nil
    }

    static func minimumEncoding(for string: String) -> QrCodeEncoding {
        if string.data(using: .ascii) != nil { return .ascii }
        if string.data(using: .utf8) != nil { return .utf8 }
        return .unicode
    }

    var description: String {
        switch self {
        case .ascii: return "ASCII"
        case .utf8: return "UTF-8"
        case .unicode: return "Unicode"
        }
    }
}

enum QrCodeType: Codable, CustomStringConvertible, CaseIterable {
    case standard
    case wifi
    case vcard

    var description: String {
        switch self {
        case .standard: return "Standard"
        case .wifi: return "Wi-Fi"
        case .vcard: return "vCard"
        }
    }
}

enum WifiSecurity: String, Codable, CaseIterable, Hashable {
    case none = "nopass"
    case wep = "WEP"
    case wpa = "WPA"

    var displayName: String {
        switch self {
        case .none: return "None"
        case .wep: return "WEP"
        case .wpa: return "WPA/WPA2"
        }
    }
}

struct VCardCustomField: Identifiable, Equatable, Codable, Hashable {
    var id = UUID()
    var label: String = ""
    var value: String = ""
}

struct PassLocation: Identifiable, Equatable, Codable, Hashable {
    var id = UUID()
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var relevantText: String = ""
}

enum BarcodeType: Codable, CustomStringConvertible, Identifiable, CaseIterable {
    case none
    case code128 // natively supported by PassKit
    case code93
    case code39
    case upce
    case upca
    case ean13
    case pdf417 // natively supported by PassKit
    case qr

    var description: String {
        switch self {
        case .none: return "None"
        case .code128: return "Code 128"
        case .code93: return "Code 93"
        case .code39: return "Code 39"
        case .upce: return "UPC-E"
        case .upca: return "UPC-A"
        case .ean13: return "EAN-13"
        case .pdf417: return "PDF417"
        case .qr: return "QR Code"
        }
    }

    var id: Self { self }
}

enum ImageType: Codable, CustomStringConvertible, CaseIterable {
    case photo
    case emoji
    case symbol
    case none

    var description: String {
        switch self {
        case .photo: return "Photo"
        case .emoji: return "Emoji"
        case .symbol: return "Symbol"
        case .none: return "None"
        }
    }
}

enum BarcodeCategory: CaseIterable, CustomStringConvertible {
    case none
    case oneDimensional
    case twoDimensional

    var description: String {
        switch self {
        case .none: return "None"
        case .oneDimensional: return "1D Barcode"
        case .twoDimensional: return "2D Barcode"
        }
    }
}
