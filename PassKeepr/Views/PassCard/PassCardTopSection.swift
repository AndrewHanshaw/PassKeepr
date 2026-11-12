import PassKeeprCore
import SwiftUI

struct PassCardTopSection: View {
    var passObject: PassObject
    @Environment(\.displayScale) private var displayScale
    // Decoded logo image, cached like the strip and background images.
    // Decoding `UIImage(data:)` inline in body re-decoded the logo on every
    // body evaluation while scrolling; this decodes once per appearance,
    // downscaled to the displayed size (max 30pt tall, logos are at most
    // about 3.2x as wide as tall, so 96pt wide in device pixels covers it).
    @State private var cachedLogoImage: UIImage?

    var body: some View {
        HStack {
            if passObject.logoImage != Data() {
                VStack {
                    if let uiImage = cachedLogoImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 30)
                            .padding([.top, .leading], 8)
                    }
                    Spacer()
                }
            }
            Spacer()
            if passObject.hasHeaderFieldOneContent {
                HeaderTextField(textLabel: passObject.headerFieldOneLabel, text: passObject.headerFieldOneText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor), isCurrency: passObject.isCurrencyFieldsOn && passObject.isHeaderFieldOneCurrency, currencyCode: passObject.currencyCode)
                    .padding(.top, 5)
            }
        }
        .padding(.trailing, 10)
        .onAppear {
            decodeLogoImage()
        }
        .onChange(of: passObject.logoImage) { _, _ in
            decodeLogoImage()
        }
    }

    private func decodeLogoImage() {
        guard passObject.logoImage != Data() else {
            cachedLogoImage = nil
            return
        }
        cachedLogoImage = decodedImage(from: passObject.logoImage, maxPixelSize: 96 * displayScale)
    }
}

#Preview {
    PassCardTopSection(passObject: MockModelData().passObjects[0])
}
