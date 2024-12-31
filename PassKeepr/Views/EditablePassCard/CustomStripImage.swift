import SwiftUI

struct CustomStripImage: View {
    @Binding var passObject: PassObject
    @Binding var isCustomizeStripImagePresented: Bool

    // TODO: Handle when passObject.stripImage == Data() ?
    var body: some View {
        ZStack {
            if passObject.stripImage != Data() {
                Image(uiImage: UIImage(data: passObject.stripImage)!)
                    .resizable()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white)
                        .opacity(0.2)
                    Text("Choose a strip image")
                        .font(.system(size: 18))
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
                    .offset(x: 12, y: 12)
                    .shadow(radius: 2, x: 0, y: 0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.top, 10)
        .aspectRatio(1125 / 432, contentMode: .fit)
    }
}

#Preview {
    CustomStripImage(passObject: .constant(MockModelData().passObjects[0]), isCustomizeStripImagePresented: .constant(true))
}
