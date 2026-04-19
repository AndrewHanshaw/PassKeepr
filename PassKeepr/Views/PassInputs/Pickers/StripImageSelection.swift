import SwiftUI

struct StripImageSelection: View {
    @Binding var passObject: PassObject

    var disableControl: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Toggle("Strip Image", isOn: $passObject.isCustomStripImageOn)
                .foregroundColor(passObject.barcodeType == .qr ? .secondary : .primary)
                .padding(14)
                .listSectionBackgroundModifier()
                .disabled(disableControl || passObject.barcodeType == .qr)
                .onChange(of: passObject.barcodeType) {
                    if passObject.barcodeType == .qr {
                        passObject.isCustomStripImageOn = false
                    }
                }
                .onChange(of: passObject.isCustomStripImageOn) {
                    // When the strip image is on, the auxiliary fields share space with the secondary fields.
                    // If the strip image is on (either by the user turning it on or by importing a pass with a strip image)
                    // but there isn't any text for the first auxiliary field, turn the strip image back off
                    // This prevents the 'placeholder' for the first auxiliary field from being displayed
                    // Especially important for imported passes, since the placeholder will mess up the layout with the secondary fields
                    // So it sort of looks like the imported pass came in "wrong"
                    if passObject.isCustomStripImageOn && passObject.auxiliaryFieldOneText.isEmpty {
                        passObject.isAuxiliaryFieldOneOn = false
                    }
                }
                .onAppear {
                    if passObject.barcodeType == .qr {
                        passObject.isCustomStripImageOn = false
                    }
                }
            if passObject.barcodeType == .qr {
                Text("Strip images are not compatible with QR codes")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding([.leading, .bottom], 14)
            }
        }
    }
}

#Preview {
    StripImageSelection(passObject: .constant(MockModelData().passObjects[0]), disableControl: false)
}
