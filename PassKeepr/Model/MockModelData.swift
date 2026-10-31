// Mock ModelData to be used for preview/testing purposes

import Foundation
import PassKeeprCore

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

    init() {
        super.init()
        // Initialize with mock data
        passObjects = [PassObject.preview1, PassObject.preview2]
        encodePassObjects()
    }
}

private extension PassObject {
    static let preview1: PassObject = {
        var pass = PassObject()
        pass.group = 2
        pass.barcodeString = "1234"
        pass.barcodeType = .code128
        pass.foregroundColor = 0xFF00FF
        pass.description = "Preview pass 1"
        pass.logoSymbolName = "info.circle"
        pass.logoSymbolColor = 0x0000FF
        pass.thumbnailSymbolName = "info.circle"
        pass.thumbnailSymbolColor = 0x0000FF
        pass.associatedStoreIdentifiers = [0]
        pass.isAuxiliaryFieldOneOn = false
        pass.locations = [PassLocation(latitude: 11.111, longitude: 22.222, relevantText: "Some Text")]
        return pass
    }()

    static let preview2: PassObject = {
        var pass = PassObject()
        pass.group = 1
        pass.barcodeString = "1234"
        pass.barcodeType = .code128
        pass.isBackgroundImageOn = true
        pass.foregroundColor = 0xFF00FF
        pass.description = "Preview pass 0"
        pass.logoSymbolName = "checkmark"
        pass.logoSymbolColor = 0x0000FF
        pass.thumbnailSymbolName = "checkmark"
        pass.thumbnailSymbolColor = 0x0000FF
        pass.associatedStoreIdentifiers = [0]
        pass.isAuxiliaryFieldOneOn = false
        pass.locations = [PassLocation(latitude: 33.333, longitude: 44.444, relevantText: "Some more Text")]
        return pass
    }()
}
