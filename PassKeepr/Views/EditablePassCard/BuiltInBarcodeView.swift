import SwiftUI

struct BuiltInBarcodeView: View {
    @Binding var passObject: PassObject
    @Binding var isCustomizeBarcodePresented: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white)

            if BarcodeTypeHelpers.GetIsEnteredBarcodeValueValid(string: passObject.barcodeString, type: passObject.barcodeType) == true {
                Code128View(data: $passObject.barcodeString)
                    .padding([.top, .bottom], 15)
                    .padding([.leading, .trailing], 20)
            } else {
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
        .aspectRatio(3.4, contentMode: .fit)
        .padding([.leading, .trailing], 45)
        .padding(.bottom, 40)
    }
}

#Preview {
    BuiltInBarcodeView(passObject: .constant(MockModelData().passObjects[0]), isCustomizeBarcodePresented: .constant(true))
}
