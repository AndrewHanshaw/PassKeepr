import Foundation
import SwiftUI

public struct PassObject: Codable, Identifiable, Equatable, Hashable, Transferable {
    public static let defaultDescription: String = "PassKeepr Pass"
    public var id: UUID
    public var group: Int
    public var passIcon: Data
    public var passIconType: ImageType
    public var barcodeString: String
    public var barcodeType: BarcodeType
    public var barcodeBorder: Double
    public var stripImage: Data // PNG data for all passes that use the strip image (may be a barcode, picture, etc)
    // PNG data for all passes that use the background image. Assigning this automatically
    // recomputes `imageBackgroundBrightness` below (see `didSet`), so callers can just set it
    // directly instead of going through a separate update method.
    public var backgroundImage: Data {
        didSet {
            guard backgroundImage != oldValue else { return }
            imageBackgroundBrightness = Self.computeImageBrightness(from: backgroundImage)
            isBackgroundImageOn = backgroundImage != Data()
        }
    }

    public var isBackgroundImageOn: Bool

    // Cached brightness classification of `backgroundImage`, kept in sync automatically by
    // `backgroundImage`'s `didSet` rather than being recomputed every time a card is rendered.
    // `nil` means there's no background image, in which case `backgroundBrightness` falls back
    // to `backgroundColor` (which is cheap enough to compute on the fly, so it needs no cache).
    public var imageBackgroundBrightness: BackgroundBrightness? = nil
    public var logoImage: Data // PNG data for all passes that use the logo image
    public var logoImageType: ImageType
    public var thumbnailImage: Data // PNG data for thumbnail image (90x90 points, aspect ratio 2:3 to 3:2)
    public var thumbnailImageType: ImageType
    public var qrCodeCorrectionLevel: QrCodeCorrectionLevel
    public var qrCodeEncoding: QrCodeEncoding
    public var qrCodeType: QrCodeType
    public var altText: String
    public var foregroundColor: UInt
    public var backgroundColor: UInt
    public var labelColor: UInt
    public var description: String
    public var headerFieldOneLabel: String
    public var headerFieldOneText: String
    public var isHeaderFieldTwoOn: Bool
    public var headerFieldTwoLabel: String
    public var headerFieldTwoText: String
    /* Technically, PassKit supports a third header field, but the space available is so tight that a third one is effectively useless. Maybe this will change later */
    public var primaryFieldLabel: String
    public var primaryFieldText: String
    public var secondaryFieldOneLabel: String
    public var secondaryFieldOneText: String
    public var isSecondaryFieldTwoOn: Bool
    public var secondaryFieldTwoLabel: String
    public var secondaryFieldTwoText: String
    public var isSecondaryFieldThreeOn: Bool
    public var secondaryFieldThreeLabel: String
    public var secondaryFieldThreeText: String
    public var isAuxiliaryFieldOneOn: Bool
    public var auxiliaryFieldOneLabel: String
    public var auxiliaryFieldOneText: String
    public var isAuxiliaryFieldTwoOn: Bool
    public var auxiliaryFieldTwoLabel: String
    public var auxiliaryFieldTwoText: String
    public var isAuxiliaryFieldThreeOn: Bool
    public var auxiliaryFieldThreeLabel: String
    public var auxiliaryFieldThreeText: String
    public var isCustomStripImageOn: Bool
    public var logoSymbolName: String
    public var logoSymbolColor: UInt
    public var thumbnailSymbolName: String
    public var thumbnailSymbolColor: UInt
    public var passIconSymbolName: String
    public var passIconSymbolColor: UInt
    public var passIconBackgroundColor: UInt
    public var associatedStoreIdentifiers: [Int]
    // WiFi QR Code
    public var wifiSSID: String
    public var wifiPassword: String
    public var wifiSecurity: WifiSecurity
    public var wifiIsHidden: Bool
    // vCard QR Code
    public var vcardFirstName: String
    public var vcardLastName: String
    public var vcardCompany: String
    public var vcardPhone: String
    public var vcardEmail: String
    public var vcardURL: String
    public var vcardAddress: String
    public var vcardSocial: String
    public var vcardHasBirthday: Bool
    public var vcardBirthday: Date
    public var vcardCustomFields: [VCardCustomField]
    public var hasExpirationDate: Bool
    public var expirationDate: Date
    public var locations: [PassLocation]
    public var isCurrencyFieldsOn: Bool
    public var currencyCode: String
    public var isPrimaryFieldCurrency: Bool
    public var isHeaderFieldOneCurrency: Bool
    public var isHeaderFieldTwoCurrency: Bool
    public var isSecondaryFieldOneCurrency: Bool
    public var isSecondaryFieldTwoCurrency: Bool
    public var isSecondaryFieldThreeCurrency: Bool
    public var isAuxiliaryFieldOneCurrency: Bool
    public var isAuxiliaryFieldTwoCurrency: Bool
    public var isAuxiliaryFieldThreeCurrency: Bool
    public var isCoupon: Bool

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
        case isCoupon
        case isBackgroundImageOn
    }

    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .data)
    }
}

public extension PassObject {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let defaultIcon = Self.defaultPassIconData()

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
        isCoupon = try c.decodeIfPresent(Bool.self, forKey: .isCoupon) ?? false
        let persistedIsBackgroundImageOn = try c.decodeIfPresent(Bool.self, forKey: .isBackgroundImageOn)
        isBackgroundImageOn = persistedIsBackgroundImageOn ?? false

        // Migration: passes saved before `imageBackgroundBrightness` existed won't have it persisted.
        // Compute it once here so older saved passes with a background image get correct contrast
        // immediately, instead of waiting until the user next edits the background.
        if imageBackgroundBrightness == nil, backgroundImage != Data() {
            imageBackgroundBrightness = Self.computeImageBrightness(from: backgroundImage)
        }

        // Migration: passes saved before `isBackgroundImageOn` existed won't have it persisted.
        // Sync it based on whether there's actually a background image. A persisted value (including
        // `false` alongside retained image data, e.g. after enabling Coupon Pass) must be preserved.
        if persistedIsBackgroundImageOn == nil, backgroundImage != Data() {
            isBackgroundImageOn = true
        }
    }
}

public extension PassObject {
    // The brightness bucket used to keep card chrome (shadows, strokes, text overlays) legible
    // against whatever is actually behind the card: the background image if there is one,
    // otherwise the background color. Cheap to read in both cases — the image case is kept
    // up to date automatically by `backgroundImage`'s `didSet` instead of being recalculated
    // on every access, and the color case is cheap enough to just compute here directly.
    var backgroundBrightness: BackgroundBrightness {
        if let imageBackgroundBrightness {
            return imageBackgroundBrightness
        }

        let red = CGFloat((backgroundColor >> 16) & 0xFF) / 255.0
        let green = CGFloat((backgroundColor >> 8) & 0xFF) / 255.0
        let blue = CGFloat(backgroundColor & 0xFF) / 255.0
        return BackgroundBrightness(brightness: (0.299 * red) + (0.587 * green) + (0.114 * blue))
    }

    static func defaultPassIconData() -> Data {
        let bundle = Bundle.module
        return (try? Data(contentsOf: bundle.url(forResource: "DefaultPassIcon", withExtension: "png") ?? URL(fileURLWithPath: ""))) ?? Data()
    }

    internal static func computeImageBrightness(from data: Data) -> BackgroundBrightness? {
        guard data != Data(), let image = ImageIOHelpers.decode(data) else { return nil }
        let brightness = ImageIOHelpers.averageBrightness(of: image, maxWidth: 40, maxHeight: 40) ?? 0.5
        return BackgroundBrightness(brightness: brightness)
    }
}

public extension PassObject {
    init() {
        let defaultIcon = Self.defaultPassIconData()

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
            isBackgroundImageOn: false,
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
            isAuxiliaryFieldThreeCurrency: false,
            isCoupon: false
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
            isBackgroundImageOn: isBackgroundImageOn,
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
            isAuxiliaryFieldThreeCurrency: isAuxiliaryFieldThreeCurrency,
            isCoupon: isCoupon
        )
    }
}

public enum QrCodeCorrectionLevel: Codable, CustomStringConvertible, CaseIterable {
    case low
    case medium
    case quartile
    case high

    public var description: String {
        switch self {
        case .low: return "L"
        case .medium: return "M"
        case .quartile: return "Q"
        case .high: return "H"
        }
    }
}

public enum QrCodeEncoding: Codable, CustomStringConvertible, CaseIterable {
    case ascii
    case utf8
    case unicode

    public func toStringEncoding() -> String.Encoding {
        switch self {
        case .ascii: return .ascii
        case .utf8: return .utf8
        case .unicode: return .unicode
        }
    }

    public var ianaEncodingName: String {
        switch self {
        case .ascii: return "us-ascii"
        case .utf8: return "utf-8"
        case .unicode: return "utf-16"
        }
    }

    public func isCompatible(with string: String) -> Bool {
        string.data(using: toStringEncoding()) != nil
    }

    public static func minimumEncoding(for string: String) -> QrCodeEncoding {
        if string.data(using: .ascii) != nil { return .ascii }
        if string.data(using: .utf8) != nil { return .utf8 }
        return .unicode
    }

    public var description: String {
        switch self {
        case .ascii: return "ASCII"
        case .utf8: return "UTF-8"
        case .unicode: return "Unicode"
        }
    }
}

public enum QrCodeType: Codable, CustomStringConvertible, CaseIterable {
    case standard
    case wifi
    case vcard

    public var description: String {
        switch self {
        case .standard: return "Standard"
        case .wifi: return "Wi-Fi"
        case .vcard: return "vCard"
        }
    }
}

public enum WifiSecurity: String, Codable, CaseIterable, Hashable {
    case none = "nopass"
    case wep = "WEP"
    case wpa = "WPA"

    public var displayName: String {
        switch self {
        case .none: return "None"
        case .wep: return "WEP"
        case .wpa: return "WPA/WPA2"
        }
    }
}

public struct VCardCustomField: Identifiable, Equatable, Codable, Hashable {
    public var id = UUID()
    public var label: String = ""
    public var value: String = ""

    public init(id: UUID = UUID(), label: String = "", value: String = "") {
        self.id = id
        self.label = label
        self.value = value
    }
}

public struct PassLocation: Identifiable, Equatable, Codable, Hashable {
    public var id = UUID()
    public var latitude: Double = 0.0
    public var longitude: Double = 0.0
    public var relevantText: String = ""

    public init(id: UUID = UUID(), latitude: Double = 0.0, longitude: Double = 0.0, relevantText: String = "") {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.relevantText = relevantText
    }
}

public enum BarcodeType: Codable, CustomStringConvertible, Identifiable, CaseIterable {
    case none
    case code128 // natively supported by PassKit
    case code93
    case code39
    case upce
    case upca
    case ean13
    case pdf417 // natively supported by PassKit
    case qr

    public var description: String {
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

    public var id: Self { self }
}

public enum ImageType: Codable, CustomStringConvertible, CaseIterable {
    case photo
    case emoji
    case symbol
    case none

    public var description: String {
        switch self {
        case .photo: return "Photo"
        case .emoji: return "Emoji"
        case .symbol: return "Symbol"
        case .none: return "None"
        }
    }
}

public enum BarcodeCategory: CaseIterable, CustomStringConvertible {
    case none
    case oneDimensional
    case twoDimensional

    public var description: String {
        switch self {
        case .none: return "None"
        case .oneDimensional: return "1D Barcode"
        case .twoDimensional: return "2D Barcode"
        }
    }
}
