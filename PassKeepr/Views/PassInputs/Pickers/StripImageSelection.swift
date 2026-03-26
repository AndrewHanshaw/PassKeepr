import SwiftUI

struct StripImageSelection: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var passObject: PassObject

    var disableControl: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Toggle("Strip Image", isOn: $passObject.isCustomStripImageOn)
                .foregroundColor(passObject.barcodeType == .qr ? .secondary : .primary)
                .padding(14)
                .listSectionBackgroundModifier()
                .disabled(disableControl || passObject.barcodeType == .qr)
                .onChange(of: passObject.barcodeType) { newType in
                    if newType == .qr {
                        passObject.isCustomStripImageOn = false
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
