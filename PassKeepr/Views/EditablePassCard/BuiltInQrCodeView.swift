import SwiftUI

struct BuiltInQrCodeView: View {
    var placeholderColor: Color
    @Binding var passObject: PassObject
    @Binding var isCustomizeQrCodePresented: Bool

    var body: some View {
        ZStack {
            if passObject.barcodeString != "" {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)

                QRCodeView(data: passObject.barcodeString, correctionLevel: passObject.qrCodeCorrectionLevel)
                    .padding(7)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                        .foregroundColor(placeholderColor)
                        .opacity(placeholderColor == Color.gray ? 0.5 : 0.3)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white)
                        .opacity(0.2)
                    Text("Enter QR Code Data")
                }
            }

//          TODO: check for valid qr code data
//          else if (){
//                    Text("Invalid QR Code Data")
//                }

            Button(action: {
                isCustomizeQrCodePresented.toggle()
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
        .aspectRatio(1, contentMode: .fit)
        .padding([.leading, .trailing], 55)
        .padding(.bottom, 15)
    }
}

#Preview {
    BuiltInQrCodeView(placeholderColor: Color.black, passObject: .constant(MockModelData().passObjects[0]), isCustomizeQrCodePresented: .constant(true))
}
