import SwiftUI

struct InvalidBarcodeView: View {
    @Environment(\.colorScheme) var colorScheme
    var isEmpty: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                .foregroundColor(Color.gray)
                .opacity(0.7)
                .padding(7)

            Text(isEmpty ? "Enter Barcode Data" : "Invalid Barcode Data")
                .font(Font.system(size: 18))
                .foregroundColor(Color.gray)
                .opacity(0.7)
        }
    }
}

#Preview {
    InvalidBarcodeView(isEmpty: false)
}
