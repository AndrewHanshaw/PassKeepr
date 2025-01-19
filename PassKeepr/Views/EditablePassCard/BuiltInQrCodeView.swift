import SwiftUI

struct BuiltInQrCodeView: View {
    @Binding var passObject: PassObject
    @Binding var isCustomizeQrCodePresented: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white)

            if passObject.qrCodeString != "" {
                QRCodeView(data: passObject.qrCodeString, correctionLevel: passObject.qrCodeCorrectionLevel)
                    .padding(7)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
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
                    .shadow(color: .gray, radius: 2, x: 0, y: 0)
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
    BuiltInQrCodeView(passObject: .constant(MockModelData().passObjects[0]), isCustomizeQrCodePresented: .constant(true))
}
