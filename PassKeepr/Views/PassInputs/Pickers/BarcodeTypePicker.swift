import SwiftUI

struct BarcodeTypePicker: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var pass: PassObject

    @State private var category: BarcodeCategory

    init(pass: Binding<PassObject>) {
        _pass = pass
        _category = State(initialValue: pass.wrappedValue.barcodeType.toBarcodeCategory())
    }

    var body: some View {
        HStack {
            Text("Barcode Type")
            Spacer()
            Picker("Barcode Type", selection: $category) {
                ForEach(BarcodeCategory.allCases, id: \.self) { type in
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
                    .tag(type)
                }
            }
            .accentColor(.secondary)
        }
        .padding([.top, .bottom], 10)
        .padding(.trailing, 4)
        .padding(.leading, 12)
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
    BarcodeTypePicker(pass: .constant(MockModelData().passObjects[0]))
}
