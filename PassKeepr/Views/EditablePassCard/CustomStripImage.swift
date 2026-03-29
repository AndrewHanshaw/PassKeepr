import SwiftUI

struct CustomStripImage: View {
    var backgroundBrightness: BackgroundBrightness
    var disableButton: Bool
    @Binding var passObject: PassObject
    @Binding var isCustomizeStripImagePresented: Bool

    // TODO: Handle when passObject.stripImage == Data() ?
    var body: some View {
        let aspectRatio: CGFloat? = {
            if passObject.stripImage != Data(), let uiImage = UIImage(data: passObject.stripImage) {
                return uiImage.size.width / uiImage.size.height
            }
            return PassKitConstants.StripImage.aspectRatio
        }()

        ZStack {
            if passObject.stripImage != Data(), let uiImage = UIImage(data: passObject.stripImage) {
                Image(uiImage: uiImage)
                    .resizable()
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(Color.black.opacity(0.1))
                            .frame(width: 2)
                    }
                    .overlay(alignment: .trailing) {
                        Rectangle()
                            .fill(Color.black.opacity(0.1))
                            .frame(width: 2)
                    }
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                        .foregroundColor(backgroundBrightness.overwriteForegroundColor)
                        .opacity(backgroundBrightness.overwriteOpacityRoundedRectangle)
                    Text("Add a Strip Image")
                        .font(.system(size: 18))
                        .foregroundColor(backgroundBrightness.overwriteForegroundColor)
                        .opacity(backgroundBrightness.overwriteOpacity)
                }
                .padding([.leading, .trailing], 10)
            }

            Button(action: {
                isCustomizeStripImagePresented.toggle()
            }) {
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.green, .white)
                    .font(.system(size: 24))
                    .offset(x: passObject.stripImage != Data() ? 12 : 0, y: 12)
                    .shadow(radius: 2, x: 0, y: 0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(disableButton)
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
    }
}

#Preview {
    CustomStripImage(backgroundBrightness: .normal, disableButton: false, passObject: .constant(MockModelData().passObjects[0]), isCustomizeStripImagePresented: .constant(true))
}
