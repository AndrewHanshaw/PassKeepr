import SwiftUI

struct BuiltInBarcodeView: View {
    var placeholderColor: Color
    @Binding var passObject: PassObject
    @Binding var isCustomizeBarcodePresented: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white)
                .shadow(radius: 0.2)

            VStack {
                if BarcodeTypeHelpers.GetIsEnteredBarcodeValueValid(string: passObject.barcodeString, type: passObject.barcodeType) == true {
                    if passObject.barcodeType == BarcodeType.code128 {
                        Code128View(data: passObject.barcodeString)
                            .padding(.top, 15)
                            .padding(.bottom, passObject.altText == "" ? 15 : 0)
                            .padding([.leading, .trailing], 20)
                    } else if passObject.barcodeType == BarcodeType.pdf417 {
                        PDF417View(data: passObject.barcodeString)
                            .padding(.bottom, passObject.altText == "" ? 8 : 0)
                            .padding([.top, .leading, .trailing], 8)
                    }
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                            .foregroundColor(placeholderColor)
                            .opacity(placeholderColor == Color.gray ? 0.5 : 0.3)
                            .padding(7)
                        if passObject.barcodeString == "" {
                            Text("Enter Barcode Data")
                                .foregroundColor(placeholderColor)
                                .opacity(placeholderColor == Color.gray ? 0.7 : 0.4)
                        } else {
                            Text("Invalid Barcode Data")
                                .foregroundColor(placeholderColor)
                                .opacity(placeholderColor == Color.gray ? 0.7 : 0.4)
                        }
                    }
                }

                if passObject.altText != "" {
                    Text(passObject.altText)
                        .font(.system(size: 16))
                        .foregroundColor(Color.black)
                        .padding(.bottom, passObject.barcodeType == BarcodeType.code128 ? 8 : 0)
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
    BuiltInBarcodeView(placeholderColor: Color.black, passObject: .constant(MockModelData().passObjects[0]), isCustomizeBarcodePresented: .constant(true))
}
