import SwiftUI

struct PassInput: View {
    @Binding var pass: PassObject

    var body: some View {
        switch pass.passType {
        case PassType.identificationPass:
            IdentificationInput(passObject: $pass)
        case PassType.barcodePass:
            BarcodeInput(passObject: $pass)
        case PassType.qrCodePass:
            QRCodeInput(passObject: $pass)
        case PassType.notePass:
            NoteInput(passObject: $pass)
        case PassType.businessCardPass:
            BusinessCardInput(passObject: $pass)
        case PassType.picturePass:
            PictureInput()
        }
    }
}

#Preview {
    PassInput(pass: .constant(MockModelData().PassObjects[0]))
}
