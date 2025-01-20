import SwiftUI

struct BuiltInQrCodeView: View {
    @State var backgroundSize: CGSize = CGSizeZero
    var placeholderColor: Color
    @Binding var passObject: PassObject
    @Binding var isCustomizeQrCodePresented: Bool

    var body: some View {
        ZStack {
            VStack {
                if passObject.barcodeString != "" {
                    QRCodeView(data: passObject.barcodeString, correctionLevel: passObject.qrCodeCorrectionLevel, encoding: passObject.qrCodeEncoding)
                        .padding([.top, .leading, .trailing], 5)
                        .padding(.bottom, passObject.altText == "" ? 5 : 0)
                        .aspectRatio(1, contentMode: .fit)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                            .foregroundColor(placeholderColor)
                            .opacity(placeholderColor == Color.gray ? 0.5 : 0.3)
                            .padding(5)
                        Text("Enter\nQR Code\nData")
                            .multilineTextAlignment(.center)
                            .foregroundColor(placeholderColor)
                            .opacity(placeholderColor == Color.gray ? 0.7 : 0.4)
                    }
                    .aspectRatio(1, contentMode: .fit)
                }

                if passObject.altText != "" {
                    Text(passObject.altText)
                        .font(.system(size: 13))
                        .foregroundColor(Color.black)
                        .padding(.top, -8)
                        .padding([.bottom, .leading, .trailing], 8)
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)
                    .shadow(radius: 0.2)
                    .readSize(into: $backgroundSize)
            }

            Button(action: {
                isCustomizeQrCodePresented.toggle()
            }) {
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.green, .white)
                    .font(.system(size: 24))
                    .offset(x: 12, y: 12)
                    .shadow(radius: 2, x: 0, y: 0)
                    .frame(maxWidth: backgroundSize.width, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.bottom, 15)
    }
}

#Preview {
    BuiltInQrCodeView(placeholderColor: Color.black, passObject: .constant(MockModelData().passObjects[0]), isCustomizeQrCodePresented: .constant(true))
}
