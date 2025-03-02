// Mock ModelData to be used for preview/testing purposes

import Foundation

@Observable
class MockModelData: ModelData {
    override var passObjects: [PassObject] {
        get {
            super.passObjects
        }
        set {
            super.passObjects = newValue
        }
    }

    override init() {
        super.init()
        // Initialize with mock data
        passObjects = [PassObject.preview1, PassObject.preview2]
        encodePassObjects()
    }
}

private extension PassObject {
    static let preview1 = PassObject(
        id: UUID(),
        passIcon: (try? Data(contentsOf: Bundle.main.url(forResource: "DefaultPassIcon", withExtension: "png") ?? URL(fileURLWithPath: ""))) ?? Data(),
        barcodeString: "1234",
        barcodeType: BarcodeType.code128,
        barcodeBorder: 0,
        stripImage: Data(),
        backgroundImage: Data(),
        logoImage: Data(),
        logoImageType: LogoImageType.none,
        qrCodeCorrectionLevel: QrCodeCorrectionLevel.medium,
        qrCodeEncoding: QrCodeEncoding.ascii,
        altText: "",
        foregroundColor: 0xFF00FF,
        backgroundColor: 0xFFFFFF,
        labelColor: 0x000000,
        description: "Preview pass 1",
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
        isCustomStripImageOn: false,
        frame: .zero
    )

    static let preview2 = PassObject(
        id: UUID(),
        passIcon: (try? Data(contentsOf: Bundle.main.url(forResource: "DefaultPassIcon", withExtension: "png") ?? URL(fileURLWithPath: ""))) ?? Data(),
        barcodeString: "1234",
        barcodeType: BarcodeType.code128,
        barcodeBorder: 0,
        stripImage: Data(),
        backgroundImage: Data(),
        logoImage: Data(),
        logoImageType: LogoImageType.none,
        qrCodeCorrectionLevel: QrCodeCorrectionLevel.medium,
        qrCodeEncoding: QrCodeEncoding.ascii,
        altText: "",
        foregroundColor: 0xFF00FF,
        backgroundColor: 0xFFFFFF,
        labelColor: 0x000000,
        description: "Preview pass 0",
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
        isCustomStripImageOn: false,
        frame: .zero
    )
}
