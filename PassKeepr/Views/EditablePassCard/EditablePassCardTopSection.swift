import SwiftUI

struct EditablePassCardTopSection: View {
    var backgroundBrightness: BackgroundBrightness
    var disableButtons: Bool

    @Binding var passObject: PassObject
    @Binding var isCustomizeLogoImagePresented: Bool

    var body: some View {
        HStack(spacing: 0) {
            Group {
                if passObject.logoImage != Data() {
                    logoImage
                } else {
                    placeholder
                }
            }
            .overlay {
                Button(action: {
                    isCustomizeLogoImagePresented.toggle()
                }) {
                    Image("custom.photo.circle.fill")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.green, .white)
                        .font(.system(size: 24))
                        .offset(x: 12, y: 12)
                        .shadow(radius: 2, x: 0, y: 0)
                }
                .disabled(disableButtons)
            }
            .zIndex(1)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer() // Always sits in the exact middle of the view regardless of how wide the logo or header fields are.
                .frame(width: 60)

            HStack(spacing: 0) {
                if passObject.isHeaderFieldTwoOn {
                    EditableHeaderTextField(backgroundBrightness: backgroundBrightness, disableButton: disableButtons, textLabel: $passObject.headerFieldTwoLabel, text: $passObject.headerFieldTwoText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor), isCurrency: passObject.isCurrencyFieldsOn && passObject.isHeaderFieldTwoCurrency, currencyCode: passObject.currencyCode)
                        .padding(.trailing, 10)
                }

                EditableHeaderTextField(backgroundBrightness: backgroundBrightness, disableButton: disableButtons, textLabel: $passObject.headerFieldOneLabel, text: $passObject.headerFieldOneText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor), isCurrency: passObject.isCurrencyFieldsOn && passObject.isHeaderFieldOneCurrency, currencyCode: passObject.currencyCode)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    @ViewBuilder
    private var logoImage: some View {
        // Small logo images can be rendered at their native size. Anything larger needs to be shrunk down
        if let uiImage = UIImage(data: passObject.logoImage),
           uiImage.size.width < PassKitConstants.LogoImage.width && uiImage.size.height < PassKitConstants.LogoImage.height
        {
            Image(uiImage: uiImage)
                .frame(alignment: .leading)
        } else if let uiImage = UIImage(data: passObject.logoImage) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(alignment: .leading)
        }
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                .foregroundColor(backgroundBrightness.overwriteForegroundColor)
                .opacity(backgroundBrightness.overwriteOpacityRoundedRectangle)
            Text("Logo Image")
                .foregroundColor(backgroundBrightness.overwriteForegroundColor)
                .opacity(backgroundBrightness.overwriteOpacity)
                .padding(.horizontal, 6)
        }
    }
}

#Preview {
    EditablePassCardTopSection(backgroundBrightness: .normal, disableButtons: false, passObject: .constant(MockModelData().passObjects[0]), isCustomizeLogoImagePresented: .constant(false))
}
