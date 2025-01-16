import Vision

extension VNBarcodeSymbology {
    func toBarcodeType() -> BarcodeType? {
        switch self {
        case VNBarcodeSymbology.code128:
            return BarcodeType.code128
        case VNBarcodeSymbology.code39:
            return BarcodeType.code39
        case VNBarcodeSymbology.code93:
            return BarcodeType.code93
        case VNBarcodeSymbology.upce:
            return BarcodeType.upce
        default:
            return nil
        }
    }
}
