import SwiftUI

struct BuiltInQrCodeView: View {
    var backgroundBrightness: BackgroundBrightness
    var disableButton: Bool

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
                            .foregroundColor(backgroundBrightness.overwriteForegroundColor)
                            .opacity(backgroundBrightness.overwriteOpacityRoundedRectangle)
                            .padding(5)
                        Text("Enter\nQR Code\nData")
                            .multilineTextAlignment(.center)
                            .foregroundColor(backgroundBrightness.overwriteForegroundColor)
                            .opacity(backgroundBrightness.overwriteOpacity)
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
            }
            .overlay(alignment: .bottomTrailing) {
                Button(action: {
                    isCustomizeQrCodePresented.toggle()
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.green, .white)
                        .font(.system(size: 24))
                        .offset(x: 12, y: 12)
                        .shadow(radius: 2, x: 0, y: 0)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(disableButton)
            }
        }
        .padding(.bottom, 15)
    }
}

#Preview {
    BuiltInQrCodeView(backgroundBrightness: .normal, disableButton: false, passObject: .constant(MockModelData().passObjects[0]), isCustomizeQrCodePresented: .constant(true))
}
