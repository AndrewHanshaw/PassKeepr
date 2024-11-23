import SwiftUI
import Vision

struct BarcodeInput: View {
    @Binding var passObject: PassObject

    @State private var scannedCode = ""
    @State private var scannedSymbology: VNBarcodeSymbology?
    @State private var isScannerPresented = false
    @State private var useScannedData = false
    @State private var showAlert: Bool = false

    @Environment(\.displayScale) var displayScale

    var body: some View {
        Section {
            Button(
                action: { isScannerPresented.toggle() },
                label: {
                    HStack {
                        Spacer()
                        Text("Scan Existing Barcode")
                            .foregroundColor(Color.accentColor)
                            .disabled(false)
                            .font(.system(size: 20))
                        Spacer()
                    }
                    .padding([.top, .bottom], 10)
                }
            )
            .sheet(isPresented: $isScannerPresented) {
                ScannerView(scannedData: $scannedCode, scannedSymbology: $scannedSymbology, showScanner: $isScannerPresented)
                    .edgesIgnoringSafeArea(.bottom)
                    .presentationDragIndicator(.visible)
            }
        }
        .listSectionSeparator(.hidden)

        Section {
            Text("Or:")
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.system(size: 20))
                .foregroundColor(.secondary)
        }
        .listSectionSpacing(0)
        .listRowBackground(Color.clear)

        Section {
            HStack {
                Picker("Barcode Type", selection: $passObject.barcodeType) {
                    ForEach(BarcodeType.allCases, id: \.self) { type in
                        Text(String(describing: type))
                    }
                }
                Spacer().frame(width: 25)
            }
            .overlay(
                HStack {
                    Spacer()
                    Button(
                        action: {
                            showAlert.toggle()
                        },
                        label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(Color(.secondaryLabel))
                        }
                    )
                    .buttonStyle(PlainButtonStyle())
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text(String(describing: passObject.barcodeType)),
                              message: Text(BarcodeTypeHelpers.GetBarcodeTypeDescription(passObject.barcodeType)),
                              dismissButton: .default(Text("OK")))
                    }
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .layoutPriority(1)

            LabeledContent {
                TextField("Barcode Data", text: $passObject.barcodeString)
                    .keyboardType(BarcodeTypeHelpers.keyboardTypeForTextField(type: $passObject.barcodeType))
            } label: {
                Text("Data")
            }
        } footer: {
            if !IsScannedBarcodeSupported(symbology: scannedSymbology) {
                Text("Scanned code was not a valid barcode")
            }
        }

        Section {
            if BarcodeTypeHelpers.GetIsEnteredBarcodeValueValid(string: passObject.barcodeString, type: passObject.barcodeType) == true {
                switch passObject.barcodeType {
                case BarcodeType.code39:
                    Code39View(value: $passObject.barcodeString).aspectRatio(3, contentMode: .fit)

                case BarcodeType.code93:
                    Code93View(value: $passObject.barcodeString).aspectRatio(3, contentMode: .fit)

                case BarcodeType.upce:
                    UPCEView(value: $passObject.barcodeString).aspectRatio(3, contentMode: .fit)

                case BarcodeType.code128:
                    Code128View(data: $passObject.barcodeString).aspectRatio(3, contentMode: .fit)
                }
            } else {
                if passObject.barcodeString == "" {
                    InvalidBarcodeView(ratio: 3, isEmpty: true)
                } else {
                    InvalidBarcodeView(ratio: 3, isEmpty: false)
                }
            }
        }
        .onChange(of: scannedCode) {
            passObject.barcodeString = scannedCode
            passObject.barcodeType = scannedSymbology?.toBarcodeType() ?? BarcodeType.code128
        }
        .onChange(of: passObject.barcodeString) { _, _ in
            render()
        }
        .onAppear { render() }
    }

    @MainActor func render() {
        // Strip image size according to
        // https://help.passkit.com/en/articles/2214902-what-are-the-optimum-image-sizes
        // (Seems to be accurate)
        let imageWidth = 1125.0
        let imageHeight = 432.0

        switch passObject.barcodeType {
        case BarcodeType.code39:
            passObject.stripImage = ImageRenderer(content:
                Code39View(value: $passObject.barcodeString).frame(width: imageWidth, height: imageHeight)
            ).uiImage?.pngData() ?? Data()

        case BarcodeType.code93:
            passObject.stripImage = ImageRenderer(content:
                Code93View(value: $passObject.barcodeString).frame(width: imageWidth, height: imageHeight)
            ).uiImage?.pngData() ?? Data()

        case BarcodeType.upce:
            passObject.stripImage = ImageRenderer(content:
                UPCEView(value: $passObject.barcodeString).frame(width: imageWidth, height: imageHeight)
            ).uiImage?.pngData() ?? Data()

        default:
            break
        }
    }
}

func IsScannedBarcodeSupported(symbology: VNBarcodeSymbology?) -> Bool {
    if symbology == nil {
        return false
    }
    if (symbology != VNBarcodeSymbology.code128) || (symbology != VNBarcodeSymbology.code93) || (symbology != VNBarcodeSymbology.code39) || (symbology != VNBarcodeSymbology.upce) {
        return true
    }

    return false
}

#Preview {
    BarcodeInput(passObject: .constant(MockModelData().passObjects[0]))
}
