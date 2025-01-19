import SwiftUI

struct BuiltInQrCodeView: View {
    var placeholderColor: Color
    @Binding var passObject: PassObject
    @Binding var isCustomizeQrCodePresented: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white)
                .shadow(radius: 0.2)
            if passObject.barcodeString != "" {
                QRCodeView(data: passObject.barcodeString, correctionLevel: passObject.qrCodeCorrectionLevel, encoding: passObject.qrCodeEncoding)
                    .padding(7)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                        .foregroundColor(placeholderColor)
                        .opacity(placeholderColor == Color.gray ? 0.5 : 0.3)
                        .padding(7)
                    Text("Enter QR Code Data")
                        .foregroundColor(placeholderColor)
                        .opacity(placeholderColor == Color.gray ? 0.7 : 0.4)
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
