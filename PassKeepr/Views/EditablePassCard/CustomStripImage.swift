import SwiftUI

struct CustomStripImage: View {
    var placeholderColor: Color
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
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                        .foregroundColor(placeholderColor)
                        .opacity(placeholderColor == Color.gray ? 0.5 : 0.3)
                    Text("Add a Strip Image")
                        .font(.system(size: 18))
                        .foregroundColor(placeholderColor)
                        .opacity(placeholderColor == Color.gray ? 0.7 : 0.4)
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
        .padding(.top, 10)
        .aspectRatio(aspectRatio, contentMode: .fit)
    }
}

#Preview {
    CustomStripImage(placeholderColor: Color.black, disableButton: false, passObject: .constant(MockModelData().passObjects[0]), isCustomizeStripImagePresented: .constant(true))
}
