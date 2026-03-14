import SwiftUI

struct EditablePassCardTopSection: View {
    var backgroundBrightness: BackgroundBrightness
    var disableButtons: Bool

    @Binding var passObject: PassObject
    @Binding var isCustomizeLogoImagePresented: Bool

    var body: some View {
        let aspectRatio: CGFloat? = {
            if passObject.logoImage != Data(), let uiImage = UIImage(data: passObject.logoImage) {
                return uiImage.size.width / uiImage.size.height
            }
            return PassKitConstants.LogoImage.aspectRatio
        }()

        GeometryReader { geometry in
            HStack {
                ZStack {
                    if passObject.logoImage != Data() {
                        logoImage
                    } else {
                        placeholder
                    }

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
                .frame(maxWidth: geometry.size.width * 0.64)
                .fixedSize(horizontal: true, vertical: false)
                .sheet(isPresented: $isCustomizeLogoImagePresented) {
                    CustomizeLogoImage(passObject: $passObject)
                        .edgesIgnoringSafeArea(.bottom)
                }

                Spacer()
                HStack {
                    if passObject.isHeaderFieldTwoOn {
                        EditableHeaderTextField(backgroundBrightness: backgroundBrightness, disableButton: disableButtons, textLabel: $passObject.headerFieldTwoLabel, text: $passObject.headerFieldTwoText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                            .padding(.trailing, 10)
                    }

                    EditableHeaderTextField(backgroundBrightness: backgroundBrightness, disableButton: disableButtons, textLabel: $passObject.headerFieldOneLabel, text: $passObject.headerFieldOneText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                        .padding(.trailing, 5)
                }
                .padding(.top, 4)
                .frame(width: geometry.size.width * 0.36)
            }
            .frame(width: geometry.size.width)
        }
    }

    @ViewBuilder
    private var logoImage: some View {
        // Small logo images can be rendered at their native size. Anything larger needs to be shrunk down
        if let uiImage = UIImage(data: passObject.logoImage),
           uiImage.size.width < PassKitConstants.LogoImage.width && uiImage.size.height < PassKitConstants.LogoImage.height
        {
            Image(uiImage: uiImage)
                .frame(maxHeight: .infinity, alignment: .center)
        } else if let uiImage = UIImage(data: passObject.logoImage) {
            let aspectRatio = uiImage.size.width / uiImage.size.height
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(aspectRatio, contentMode: .fit)
        }
    }

    private var placeholder: some View {
        Group {
            RoundedRectangle(cornerRadius: 5)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                .foregroundColor(backgroundBrightness.overwriteForegroundColor)
                .opacity(backgroundBrightness.overwriteOpacityRoundedRectangle)
            Text("Logo Image")
                .foregroundColor(backgroundBrightness.overwriteForegroundColor)
                .opacity(backgroundBrightness.overwriteOpacity)
        }
        .aspectRatio(PassKitConstants.LogoImage.aspectRatio, contentMode: .fit)
    }
}

#Preview {
    EditablePassCardTopSection(backgroundBrightness: .normal, disableButtons: false, passObject: .constant(MockModelData().passObjects[0]), isCustomizeLogoImagePresented: .constant(false))
}
