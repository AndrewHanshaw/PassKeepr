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
                Text("Enter QR Code Data")
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
    }
}

#Preview {
    BuiltInQrCodeView(passObject: .constant(MockModelData().passObjects[0]), isCustomizeQrCodePresented: .constant(true))
}
