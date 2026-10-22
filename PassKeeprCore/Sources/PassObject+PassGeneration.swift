import Foundation

// Pass generation decisions that depend only on the pass's own data
// (which pass style it is and which images belong in the generated pass).
// GeneratePass uses these to create the pass,
// and keeping them on the model means the decisions live with the data they are derived from.
extension PassObject {
    // Whether a background image can be shown for this pass's barcode type
    public var isBackgroundImageSupported: Bool {
        if (barcodeType == BarcodeType.code128) || (barcodeType == BarcodeType.pdf417) || (barcodeType == BarcodeType.qr) || (barcodeType == BarcodeType.none) {
            return true
        } else {
            return false
        }
    }

    // Whether the background image belongs in the generated package
    public var shouldIncludeBackgroundImage: Bool {
        if (isBackgroundImageOn && backgroundImage != Data()) && isBackgroundImageSupported {
            return true
        } else {
            return false
        }
    }

    // Whether there is a rendered strip barcode to show: a barcode type the app renders as an image,
    // a valid barcode value, and the generated strip data.
    // Unlike shouldAddStripImage, this does not consider the user's custom strip image.
    public var hasStripBarcodeImage: Bool {
        barcodeType.doesBarcodeUseStripImage()
            && barcodeType.isEnteredBarcodeValueValid(string: barcodeString)
            && stripImage != Data()
    }

    // Whether a strip image applies to this pass, before the background image is taken into account:
    // either a rendered strip barcode, or the user's custom strip image.
    public var shouldAddStripImage: Bool {
        hasStripBarcodeImage || (isCustomStripImageOn && stripImage != Data())
    }

    // Whether the strip image belongs in the generated package.
    // A background image wins over a strip image.
    // The two cannot coexist on one pass, the strip is the one dropped if both are defined.
    var shouldIncludeStripImage: Bool {
        shouldAddStripImage && !shouldIncludeBackgroundImage
    }

    // The pass style key for pass.json, chosen from the images the package will actually contain
    // so the style never claims an image that is not included
    var passStyleKey: String {
        if shouldIncludeBackgroundImage {
            return "eventTicket"
        } else if isCoupon { // Coupon passes can have strip images, that toggle is the next-highest priority
            return "coupon"
        } else if shouldIncludeStripImage { // non-coupon passes with strip images
            return "storeCard"
        } else {
            // Default to generic
            return "generic"
        }
    }
}
