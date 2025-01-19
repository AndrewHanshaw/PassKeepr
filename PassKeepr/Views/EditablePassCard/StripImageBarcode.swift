import SwiftUI

struct StripImageBarcodeView: View {
    @Binding var passObject: PassObject
    @Binding var isCustomizeBarcodePresented: Bool

    // TODO: Handle when passObject.stripImage == Data() ?
    var body: some View {
        ZStack {
            if BarcodeTypeHelpers.GetIsEnteredBarcodeValueValid(string: passObject.barcodeString, type: passObject.barcodeType) == true && passObject.stripImage != Data() {
                Image(uiImage: UIImage(data: passObject.stripImage)!)
                    .resizable()
            } else {
                Rectangle()
                    .fill(Color.white)
                if passObject.barcodeString == "" {
                    Text("Enter Barcode Data")
                } else {
                    Text("Invalid Barcode Data")
                }
            }

            Button(action: {
                isCustomizeBarcodePresented.toggle()
            }) {
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.green, .white)
                    .font(.system(size: 24))
                    .offset(x: 12, y: 12)
                    .shadow(color: .gray, radius: 2, x: 0, y: 0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.top, 10)
        .aspectRatio(1125 / 432, contentMode: .fit)
    }
}

#Preview {
    StripImageBarcodeView(passObject: .constant(MockModelData().passObjects[0]), isCustomizeBarcodePresented: .constant(true))
}
