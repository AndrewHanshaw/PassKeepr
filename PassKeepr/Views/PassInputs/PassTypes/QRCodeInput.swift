//
//  QRCodeInput.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 1/10/24.
//

import SwiftUI
import VisionKit

struct QRCodeInput: View {
    @Binding var qrCodeInput: String
    @Binding var correctionLevel: QrCodeCorrectionLevel

    @State private var scannedCode = ""
    @State private var scannedSymbology = ""
    @State private var isScannerPresented = false
    @State private var useScannedData = false

    var body: some View {
        Section {
            LabeledContent {
                TextField("Data", text: $qrCodeInput)
                    .onChange(of: scannedCode) {
                        qrCodeInput = scannedCode
                    }
                    .onChange(of: qrCodeInput) {
                        scannedSymbology = ""
                    }
            } label : {
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

            Picker("Correction Level", selection: $correctionLevel) {
                ForEach(QrCodeCorrectionLevel.allCases, id: \.self) { level in
                    Text(String(describing: level))
                }
            }
            .onChange(of: correctionLevel) {
                scannedSymbology = ""
            }

            QRCodeView(data: qrCodeInput, correctionLevel: correctionLevel)
        } footer: {
            if(scannedSymbology != "" && scannedSymbology != "VNBarcodeSymbologyQR") {
                Text("Scanned code was not a valid QR code")
            }
        }
    }
}

#Preview {
    QRCodeInput(qrCodeInput:.constant("Test QR Code"), correctionLevel:.constant(QrCodeCorrectionLevel.medium))
}
