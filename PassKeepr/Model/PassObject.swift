import Foundation

struct PassObject: Codable, Identifiable, Equatable, Hashable {
    var id: UUID
    var passName: String
    var passStyle: PassStyle
    var passIcon: Data
    var barcodeString: String
    var barcodeType: BarcodeType
    var barcodeBorder: Double
    var stripImage: Data // PNG data for all passes that use the strip image (may be a barcode, picture, etc)
    var backgroundImage: Data // PNG data for all passes that use the background image
    var logoImage: Data // PNG data for all passes that use the logo image
    var qrCodeCorrectionLevel: QrCodeCorrectionLevel
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
    var isPrimaryFieldOn: Bool
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
    var isCustomStripImageOn: Bool
}

extension PassObject {
    init() {
        id = UUID()
        passName = ""
        passStyle = PassStyle.generic
        passIcon = (try? Data(contentsOf: Bundle.main.url(forResource: "DefaultPassIcon", withExtension: "png") ?? URL(fileURLWithPath: ""))) ?? Data()
        barcodeString = ""
        barcodeType = BarcodeType.none
        barcodeBorder = 0
        stripImage = Data()
        backgroundImage = Data()
        logoImage = Data()
        qrCodeCorrectionLevel = QrCodeCorrectionLevel.medium
        altText = ""
        foregroundColor = 0x000000
        backgroundColor = 0xFFFFFF
        labelColor = 0x000000
        description = "A Wallet Pass generated by PassKeepr"
        isHeaderFieldTwoOn = false
        headerFieldOneLabel = ""
        headerFieldOneText = ""
        headerFieldTwoLabel = ""
        headerFieldTwoText = ""
        isPrimaryFieldOn = false
        primaryFieldLabel = ""
        primaryFieldText = ""
        secondaryFieldOneLabel = ""
        secondaryFieldOneText = ""
        isSecondaryFieldTwoOn = false
        secondaryFieldTwoLabel = ""
        secondaryFieldTwoText = ""
        isSecondaryFieldThreeOn = false
        secondaryFieldThreeLabel = ""
        secondaryFieldThreeText = ""
        isCustomStripImageOn = false
    }

    func duplicate() -> PassObject {
        var newObject = PassObject()
        newObject.passName = passName
        newObject.passStyle = passStyle
        newObject.passIcon = passIcon
        newObject.barcodeString = barcodeString
        newObject.barcodeType = barcodeType
        newObject.barcodeBorder = barcodeBorder
        newObject.stripImage = stripImage
        newObject.backgroundImage = backgroundImage
        newObject.logoImage = logoImage
        newObject.qrCodeCorrectionLevel = qrCodeCorrectionLevel
        newObject.altText = altText
        newObject.foregroundColor = foregroundColor
        newObject.backgroundColor = backgroundColor
        newObject.labelColor = labelColor
        newObject.description = description
        newObject.headerFieldOneLabel = headerFieldOneLabel
        newObject.headerFieldOneText = headerFieldOneText
        newObject.isHeaderFieldTwoOn = isHeaderFieldTwoOn
        newObject.headerFieldTwoLabel = headerFieldTwoLabel
        newObject.headerFieldTwoText = headerFieldTwoText
        newObject.isPrimaryFieldOn = isPrimaryFieldOn
        newObject.primaryFieldLabel = primaryFieldLabel
        newObject.primaryFieldText = primaryFieldText
        newObject.secondaryFieldOneLabel = secondaryFieldOneLabel
        newObject.secondaryFieldOneText = secondaryFieldOneText
        newObject.isSecondaryFieldTwoOn = isSecondaryFieldTwoOn
        newObject.secondaryFieldTwoLabel = secondaryFieldTwoLabel
        newObject.secondaryFieldTwoText = secondaryFieldTwoText
        newObject.isSecondaryFieldThreeOn = isSecondaryFieldThreeOn
        newObject.secondaryFieldThreeLabel = secondaryFieldThreeLabel
        newObject.secondaryFieldThreeText = secondaryFieldThreeText
        newObject.isCustomStripImageOn = isCustomStripImageOn
        return newObject
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

enum BarcodeType: Codable, CustomStringConvertible, Identifiable, CaseIterable {
    case none
    case code128 // natively supported by PassKit
    case code93
    case code39
    case upce
    case pdf417 // natively supported by PassKit
    case qr

    var description: String {
        switch self {
        case .none: return "None"
        case .code128: return "Code 128"
        case .code93: return "Code 93"
        case .code39: return "Code 39"
        case .upce: return "UPC-E"
        case .pdf417: return "PDF417"
        case .qr: return "QR Code"
        }
    }

    var id: Self { self }
}

enum PassStyle: Codable, CustomStringConvertible, CaseIterable {
    case boardingPass
    case coupon
    case eventTicket
    case storeCard
    case generic

    var description: String {
        switch self {
        case .boardingPass: return "boardingPass"
        case .coupon: return "coupon"
        case .eventTicket: return "eventTicket"
        case .storeCard: return "storeCard"
        case .generic: return "generic"
        }
    }
}
