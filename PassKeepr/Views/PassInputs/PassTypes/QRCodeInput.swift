import SwiftUI
import VisionKit

struct QRCodeInput: View {
    @Binding var passObject: PassObject

    @State private var scannedCode = ""
    @State private var scannedSymbology = ""
    @State private var isScannerPresented = false
    @State private var useScannedData = false

    var body: some View {
        Section {
            LabeledContent {
                TextField("Data", text: $passObject.qrCodeString)
                    .onChange(of: scannedCode) {
                        passObject.qrCodeString = scannedCode
                    }
                    .onChange(of: passObject.qrCodeString) {
                        scannedSymbology = ""
                    }
            } label: {
                Text("Payload")
            }

            Button("Open Scanner") {
                isScannerPresented.toggle()
            }
            .padding()
            .sheet(isPresented: $isScannerPresented) {
                ScannerView(scannedData: $scannedCode, scannedSymbology: $scannedSymbology, showScanner: $isScannerPresented)
                    .edgesIgnoringSafeArea(.bottom)
                    .presentationDragIndicator(.visible)
            }

            Picker("Correction Level", selection: $passObject.qrCodeCorrectionLevel) {
                ForEach(QrCodeCorrectionLevel.allCases, id: \.self) { level in
                    Text(String(describing: level))
                }
            }
            .onChange(of: passObject.qrCodeCorrectionLevel) {
                scannedSymbology = ""
            }

            QRCodeView(data: passObject.qrCodeString, correctionLevel: passObject.qrCodeCorrectionLevel)
        } footer: {
            if scannedSymbology != "" && scannedSymbology != "VNBarcodeSymbologyQR" {
                Text("Scanned code was not a valid QR code")
            }
        }
    }
}

#Preview {
    QRCodeInput(passObject: .constant(MockModelData().PassObjects[0]))
}
