import SwiftUI

struct InvalidBarcodeView: View {
    @Environment(\.colorScheme) var colorScheme
    var backgroundBrightness: BackgroundBrightness
    var isEmpty: Bool

    var body: some View {
        Rectangle()
            .fill(backgroundBrightness != .normal ? Color.clear : (colorScheme == .light ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground)))
            .foregroundColor(backgroundBrightness.overwriteForegroundColor)
            .opacity(backgroundBrightness.overwriteOpacity)
            .overlay(
                Text(isEmpty ? "Enter Barcode Data" : "Invalid Barcode Data")
                    .font(Font.system(size: 18))
                    .foregroundColor(backgroundBrightness.overwriteForegroundColor)
                    .opacity(backgroundBrightness.overwriteOpacity)
                    .textCase(nil) // Otherwise all text within the view will be all caps if this view is part of a section header
            )
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                    .foregroundColor(backgroundBrightness.overwriteForegroundColor)
                    .opacity(backgroundBrightness.overwriteOpacityRoundedRectangle)
                    .padding(7)
            }
    }
}

#Preview {
    InvalidBarcodeView(backgroundBrightness: .normal, isEmpty: false)
}
