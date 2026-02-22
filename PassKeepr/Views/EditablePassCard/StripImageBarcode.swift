import SwiftUI

struct StripImageBarcodeView: View {
    var placeholderColor: Color
    var disableButton: Bool

    @Binding var passObject: PassObject
    @Binding var isCustomizeBarcodePresented: Bool

    // TODO: Handle when passObject.stripImage == Data() ?
    var body: some View {
        ZStack {
            Group {
                if shouldShowStripBarcodeImage() {
                    Image(uiImage: UIImage(data: passObject.stripImage)!)
                        .resizable()
                } else {
                    InvalidBarcodeView(placeholderColor: placeholderColor, isEmpty: passObject.barcodeString == "")
                }
            }
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(Color.black.opacity(0.1))
                    .frame(width: 2)
            }
            .overlay(alignment: .trailing) {
                Rectangle()
                    .fill(Color.black.opacity(0.1))
                    .frame(width: 2)
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
        .aspectRatio(PassKitConstants.StripImage.aspectRatio, contentMode: .fit)
    }

    func shouldShowStripBarcodeImage() -> Bool {
        passObject.barcodeType.isEnteredBarcodeValueValid(string: passObject.barcodeString) == true && passObject.stripImage != Data()
    }
}

#Preview {
    StripImageBarcodeView(placeholderColor: Color.black, disableButton: false, passObject: .constant(MockModelData().passObjects[0]), isCustomizeBarcodePresented: .constant(true))
}
