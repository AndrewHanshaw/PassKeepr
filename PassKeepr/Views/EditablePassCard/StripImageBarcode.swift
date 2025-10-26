import SwiftUI

struct StripImageBarcodeView: View {
    var placeholderColor: Color
    var disableButton: Bool

    @Binding var passObject: PassObject
    @Binding var isCustomizeBarcodePresented: Bool

    // TODO: Handle when passObject.stripImage == Data() ?
    var body: some View {
        ZStack {
            if shouldShowStripBarcodeImage() {
                Image(uiImage: UIImage(data: passObject.stripImage)!)
                    .resizable()
            } else {
                InvalidBarcodeView(placeholderColor: placeholderColor, isEmpty: passObject.barcodeString == "")
            }

            Button(action: {
                isCustomizeBarcodePresented.toggle()
            }) {
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.green, .white)
                    .font(.system(size: 24))
                    .offset(x: shouldShowStripBarcodeImage() ? 12 : 7, y: 12)
                    .shadow(radius: 2, x: 0, y: 0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(disableButton)
        }
        .padding(.top, 10)
        .aspectRatio(1125 / 432, contentMode: .fit)
    }

    func shouldShowStripBarcodeImage() -> Bool {
        passObject.barcodeType.isEnteredBarcodeValueValid(string: passObject.barcodeString) == true && passObject.stripImage != Data()
    }
}

#Preview {
    StripImageBarcodeView(placeholderColor: Color.black, disableButton: false, passObject: .constant(MockModelData().passObjects[0]), isCustomizeBarcodePresented: .constant(true))
}
