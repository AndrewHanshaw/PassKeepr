import Foundation

class PassObjectHelpers {
    static func GetStringSingular(_ type: PassType) -> String {
        switch type {
        case PassType.identificationPass:
            return "ID Card"
        case PassType.barcodePass:
            return "Barcode Pass"
        case PassType.qrCodePass:
            return "QR Code Pass"
        case PassType.notePass:
            return "Notecard"
        case PassType.businessCardPass:
            return "Business Card"
        case PassType.picturePass:
            return "Picture Pass"
        }
    }

    static func GetStringPlural(_ type: PassType) -> String {
        switch type {
        case PassType.identificationPass:
            return "IDs"
        case PassType.barcodePass:
            return "Barcode Passes"
        case PassType.qrCodePass:
            return "QR Code Passes"
        case PassType.notePass:
            return "Notecards"
        case PassType.businessCardPass:
            return "Business Cards"
        case PassType.picturePass:
            return "Picture Passes"
        }
    }

    static func GetSystemIcon(_ type: PassType) -> String {
        switch type {
        case PassType.identificationPass:
            return "person.text.rectangle"
        case PassType.barcodePass:
            return "barcode"
        case PassType.qrCodePass:
            return "qrcode"
        case PassType.notePass:
            return "note.text"
        case PassType.businessCardPass:
            return "person.crop.square.filled.and.at.rectangle"
        case PassType.picturePass:
            return "photo"
        }
    }
}
