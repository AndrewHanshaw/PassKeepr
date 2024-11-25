import SwiftUI
import Vision
import VisionKit

struct QRCodeInput: View {
    @Binding var passObject: PassObject

    @State private var scannedCode = ""
    @State private var scannedSymbology: VNBarcodeSymbology?
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
                        scannedSymbology = nil
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
                scannedSymbology = nil
            }

            QRCodeView(data: passObject.qrCodeString, correctionLevel: passObject.qrCodeCorrectionLevel)
        } footer: {
            if scannedSymbology != nil && scannedSymbology != VNBarcodeSymbology.qr {
                Text("Scanned code is not a valid QR code")
            }
        }
    }
}

#Preview {
    QRCodeInput(passObject: .constant(MockModelData().passObjects[0]))
}
