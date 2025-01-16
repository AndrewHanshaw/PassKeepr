import SwiftUI

struct InvalidBarcodeView: View {
    @EnvironmentObject var modelData: ModelData
    @Environment(\.colorScheme) var colorScheme
    @State var ratio: CGFloat
    var isEmpty: Bool

    var body: some View {
        GeometryReader { _ in
            Rectangle()
                .fill(colorScheme == .light ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
                .overlay(
                    Text(returnString(isEmpty))
                        .font(Font.system(size: 18))
                        .textCase(nil) // Otherwise all text within the view will be all caps if this view is part of a section header
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
        return "Enter Barcode Data"
    } else {
        return "Invalid Barcode Data"
    }
}
