import SwiftUI

struct BarcodeTypePicker: View {
    @Binding var pass: PassObject

    var disableControl: Bool

    @State private var category: BarcodeCategory

    init(pass: Binding<PassObject>, disableControl: Bool) {
        _pass = pass
        self.disableControl = disableControl
        _category = State(initialValue: pass.wrappedValue.barcodeType.toBarcodeCategory())
    }

    var body: some View {
        HStack {
            Text("Barcode Type")
                .frame(maxWidth: .infinity, alignment: .leading)

            // Using Picker here causes the label text (e.g. "1D Barcode") to wrap onto
            // 2 lines after a rotation/geometry change, until the control is tapped again.
            // Building the menu manually avoids this layout-invalidation bug.
            Menu {
                ForEach(BarcodeCategory.allCases, id: \.self) { type in
                    Button {
                        category = type
                    } label: {
                        HStack {
                            Text(type.description)
                            if type == BarcodeCategory.none {
                                Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                            } else if type == BarcodeCategory.twoDimensional {
                                Image(systemName: "qrcode")
                            } else {
                                Image(systemName: "barcode")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(category.description)
                        .lineLimit(1)
                    if category == BarcodeCategory.none {
                        Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                    } else if category == BarcodeCategory.twoDimensional {
                        Image(systemName: "qrcode")
                    } else {
                        Image(systemName: "barcode")
                    }
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.secondary)
            }
            .disabled(disableControl)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
        .listSectionBackgroundModifier()
        .onChange(of: category) {
            switch category {
            case BarcodeCategory.none:
                pass.barcodeType = BarcodeType.none
            case BarcodeCategory.oneDimensional:
                pass.barcodeType = BarcodeType.code128
            case BarcodeCategory.twoDimensional:
                pass.barcodeType = BarcodeType.qr
            }
        }
        .onChange(of: pass.barcodeType) { oldType, newType in
            // Clear barcode string and strip image when a barcode that uses the strip image is selected
            if oldType.doesBarcodeUseStripImage() && !newType.doesBarcodeUseStripImage() {
                // pass.barcodeString = ""
                pass.stripImage = Data()
            }
        }
    }
}

#Preview {
    BarcodeTypePicker(pass: .constant(MockModelData().passObjects[0]), disableControl: false)
}
