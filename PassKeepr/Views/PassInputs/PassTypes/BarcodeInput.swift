import SwiftUI

struct BarcodeInput: View {
    @Binding var passObject: PassObject

    @State private var scannedCode = ""
    @State private var scannedSymbology = ""
    @State private var isScannerPresented = false
    @State private var useScannedData = false
    @State private var showAlert: Bool = false

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
        } footer: {
            HStack {
                Spacer()
                Text("Or:")
                    .font(.system(size: 20))
                Spacer()
            }
            .padding(.bottom, -999)
            .padding(.top, -10)
        }

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
            if scannedSymbology != "" && scannedSymbology != "VNBarcodeSymbologyCode128" {
                Text("Scanned code was not a valid barcode")
            }
        }

        Section {
            if BarcodeTypeHelpers.GetIsEnteredBarcodeValueValid(string: passObject.barcodeString, type: passObject.barcodeType) == true {
                switch passObject.barcodeType {
                case BarcodeType.code39:
                    Code39View(ratio: 3, value: $passObject.barcodeString)
                case BarcodeType.code93:
                    Code93View(ratio: 3, value: $passObject.barcodeString)
                case BarcodeType.upce:
                    UPCEView(ratio: 3, value: $passObject.barcodeString)
                case BarcodeType.code128:
                    Code128View(ratio: 3, data: $passObject.barcodeString)
                }
            } else {
                if passObject.barcodeString == "" {
                    InvalidBarcodeView(ratio: 3, isEmpty: true)
                } else {
                    InvalidBarcodeView(ratio: 3, isEmpty: false)
                }
            }
        }
    }
}

#Preview {
    BarcodeInput(passObject: .constant(MockModelData().PassObjects[0]))
}
