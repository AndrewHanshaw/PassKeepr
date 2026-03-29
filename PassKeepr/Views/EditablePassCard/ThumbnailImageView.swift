import SwiftUI

struct ThumbnailImageView: View {
    var backgroundBrightness: BackgroundBrightness
    var disableButton: Bool

    @Binding var passObject: PassObject
    @Binding var isCustomizeThumbnailImagePresented: Bool

    var body: some View {
        Group {
            if passObject.thumbnailImage != Data() {
                if let uiImage = UIImage(data: passObject.thumbnailImage) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                }
            } else {
                placeholder
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                isCustomizeThumbnailImagePresented.toggle()
            }) {
                Image("custom.photo.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.green, .white)
                    .font(.system(size: 20))
                    .offset(x: 10, y: 10)
                    .shadow(radius: 4, x: 0, y: 0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(disableButton)
        }
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                .foregroundColor(backgroundBrightness.overwriteForegroundColor)
                .opacity(backgroundBrightness.overwriteOpacityRoundedRectangle)
            Text("Thumbnail\nImage")
                .font(.system(size: 14))
                .foregroundColor(backgroundBrightness.overwriteForegroundColor)
                .opacity(backgroundBrightness.overwriteOpacity)
        }
    }
}

#Preview {
    ThumbnailImageView(
        backgroundBrightness: .normal,
        disableButton: false,
        passObject: .constant(MockModelData().passObjects[0]),
        isCustomizeThumbnailImagePresented: .constant(false)
    )
}
