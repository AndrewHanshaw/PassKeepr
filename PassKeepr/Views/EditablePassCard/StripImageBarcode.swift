import SwiftUI

struct StripImageBarcodeView: View {
    var placeholderColor: Color
    @Binding var passObject: PassObject
    @Binding var isCustomizeBarcodePresented: Bool

    // TODO: Handle when passObject.stripImage == Data() ?
    var body: some View {
        ZStack {
            if shouldShowStripBarcodeImage() {
                Image(uiImage: UIImage(data: passObject.stripImage)!)
                    .resizable()
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                    .foregroundColor(placeholderColor)
                    .opacity(placeholderColor == Color.gray ? 0.5 : 0.3)
                    .padding([.leading, .trailing], 5)
                if passObject.barcodeString == "" {
                    Text("Enter Barcode Data")
                        .font(Font.system(size: 16))
                        .foregroundColor(placeholderColor)
                        .opacity(placeholderColor == Color.gray ? 0.7 : 0.4)
                } else {
                    Text("Invalid Barcode Data")
                        .font(Font.system(size: 16))
                        .foregroundColor(placeholderColor)
                        .opacity(placeholderColor == Color.gray ? 0.7 : 0.4)
                }
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
        }
        .padding(.top, 10)
        .aspectRatio(1125 / 432, contentMode: .fit)
    }

    func shouldShowStripBarcodeImage() -> Bool {
        BarcodeTypeHelpers.GetIsEnteredBarcodeValueValid(string: passObject.barcodeString, type: passObject.barcodeType) == true && passObject.stripImage != Data()
    }
}

#Preview {
    StripImageBarcodeView(placeholderColor: Color.black, passObject: .constant(MockModelData().passObjects[0]), isCustomizeBarcodePresented: .constant(true))
}
