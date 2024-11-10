// Mock ModelData to be used for preview/testing purposes

import Foundation

@Observable
class MockModelData: ModelData {
    override var PassObjects: [PassObject] {
        get {
            super.PassObjects
        }
        set {
            super.PassObjects = newValue
        }
    }

    override init() {
        super.init()
        // Initialize with mock data
        PassObjects = [PassObject.preview1, PassObject.preview2]
        encodePassObjects()

        updateFilteredArray()
    }
}

private extension PassObject {
    static let preview1 = PassObject(
        id: UUID(),
        passName: "Barcode Pass 1",
        passType: PassType.barcodePass,
        passIcon: (try? Data(contentsOf: Bundle.main.url(forResource: "DefaultPassIcon", withExtension: "png") ?? URL(fileURLWithPath: ""))) ?? Data(),
        identificationString: "12345678",
        barcodeString: "1234",
        barcodeType: BarcodeType.code128,
        stripImage: Data(),
        backgroundImage: Data(),
        qrCodeString: "test",
        qrCodeCorrectionLevel: QrCodeCorrectionLevel.medium,
        noteString: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        name: "John Smith",
        title: "CEO",
        businessName: "Enron",
        phoneNumber: "5123309984",
        email: "john@enron.com",
        pictureData: Data(),
        foregroundColor: 0xFF00FF,
        backgroundColor: 0xFFFFFF,
        labelColor: 0x000000,
        description: "Preview pass 1"
    )

    static let preview2 = PassObject(
        id: UUID(),
        passName: "Barcode Pass 1",
        passType: PassType.barcodePass,
        passIcon: (try? Data(contentsOf: Bundle.main.url(forResource: "DefaultPassIcon", withExtension: "png") ?? URL(fileURLWithPath: ""))) ?? Data(),
        identificationString: "",
        barcodeString: "1234",
        barcodeType: BarcodeType.code128,
        stripImage: Data(),
        backgroundImage: Data(),
        qrCodeString: "",
        qrCodeCorrectionLevel: QrCodeCorrectionLevel.medium,
        noteString: "",
        name: "",
        title: "",
        businessName: "",
        phoneNumber: "",
        email: "",
        pictureData: Data(),
        foregroundColor: 0xFF00FF,
        backgroundColor: 0xFFFFFF,
        labelColor: 0x000000,
        description: "Preview pass 0"
    )
}
