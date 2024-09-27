import SwiftUI

struct InvalidBarcodeView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var ratio: CGFloat
    var isEmpty: Bool

    var body: some View {
        GeometryReader { _ in
            Rectangle()
                .fill(colorScheme == .light ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
                .overlay(
                    Text(returnString(isEmpty))
                )
        }
        .aspectRatio(ratio, contentMode: .fit)
    }
}

#Preview {
    InvalidBarcodeView(ratio: 1.0, isEmpty: false)
}

func returnString(_ isEmpty: Bool) -> String {
    if isEmpty == true {
        return "Enter barcode data"
    } else {
        return "Invalid barcode data"
    }
}
