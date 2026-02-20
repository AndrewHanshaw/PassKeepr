import SwiftUI

struct OffsetCroppedStripImage: View {
    @State private var size: CGSize = CGSizeZero
    var cropOffset: CGFloat
    var strip: UIImage

    var body: some View {
        Rectangle()
            .aspectRatio(PassKitConstants.StripImage.aspectRatio, contentMode: .fill)
            .overlay(
                Image(uiImage: strip)
                    .resizable()
                    .scaledToFill()
                    .offset(y: cropOffset)
            )
            .clipped()
    }
}

#Preview {
    OffsetCroppedStripImage(cropOffset: 100, strip: UIImage(systemName: "plus.circle.fill")!)
}
