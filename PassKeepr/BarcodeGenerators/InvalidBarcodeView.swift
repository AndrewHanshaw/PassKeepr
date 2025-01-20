import SwiftUI

struct InvalidBarcodeView: View {
    @Environment(\.colorScheme) var colorScheme
    var placeholderColor: Color?
    var isEmpty: Bool

    var body: some View {
        Rectangle()
            .fill(placeholderColor != nil ? Color.clear : (colorScheme == .light ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground)))
            .foregroundColor(placeholderColor != nil ? placeholderColor : .primary)
            .opacity(placeholderColor != nil ? (placeholderColor == Color.gray ? 0.7 : 0.4) : 1.0)
            .overlay(
                Text(isEmpty ? "Enter Barcode Data" : "Invalid Barcode Data")
                    .font(Font.system(size: 18))
                    .foregroundColor(placeholderColor != nil ? placeholderColor : .secondary)
                    .opacity(placeholderColor != nil ? (placeholderColor == Color.gray ? 0.7 : 0.4) : 1.0)
                    .textCase(nil) // Otherwise all text within the view will be all caps if this view is part of a section header
            )
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                    .foregroundColor(placeholderColor != nil ? placeholderColor : .secondary)
                    .opacity(placeholderColor != nil ? (placeholderColor == Color.gray ? 0.5 : 0.3) : 1.0)
                    .padding(7)
            }
    }
}

#Preview {
    InvalidBarcodeView(isEmpty: false)
}
