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
        }
    }
}

#Preview {
    QRCodeInput(qrCodeInput:.constant("Test QR Code"))
}
