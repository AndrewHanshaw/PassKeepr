import SwiftUI

struct BuiltInBarcodeView: View {
    @Binding var passObject: PassObject
    @Binding var isCustomizeBarcodePresented: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white)

            VStack {
                if BarcodeTypeHelpers.GetIsEnteredBarcodeValueValid(string: passObject.barcodeString, type: passObject.barcodeType) == true {
                    Code128View(data: $passObject.barcodeString)
                        .padding(.top, 15)
                        .padding(.bottom, passObject.altText == "" ? 15 : 0)
                        .padding([.leading, .trailing], 20)
                } else {
                    if passObject.barcodeString == "" {
                        Text("Enter Barcode Data")
                    } else {
                        Text("Invalid Barcode Data")
                    }
                }

                if passObject.altText != "" {
                    Text(passObject.altText)
                        .font(.system(size: 16))
                        .foregroundColor(Color.black)
                        .padding(.bottom, 8)
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
                    .shadow(radius: 2, x: 0, y: 0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .aspectRatio(passObject.altText == "" ? 3.4 : 3, contentMode: .fit)
        .padding([.leading, .trailing], 45)
        .padding(.bottom, 40)
    }
}

#Preview {
    BuiltInBarcodeView(passObject: .constant(MockModelData().passObjects[0]), isCustomizeBarcodePresented: .constant(true))
}
