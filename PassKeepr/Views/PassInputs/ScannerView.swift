//
//  ScannerView.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 1/27/24.
//

import SwiftUI
import VisionKit

struct ScannerView: View {
    @Binding var scannedData: String
    @Binding var scannedSymbology: String
    @Binding var showScanner: Bool

    @State private var tempScanData = ""
    @State private var tempScanSymbology = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                CodeScanner(
                    shouldStartScanning: $showScanner,
                    scannedText: $tempScanData,
                    scannedSymbology: $tempScanSymbology,
                    dataToScanFor: [.barcode(symbologies: [.qr])]
                )
            }
            else if !DataScannerViewController.isSupported {
                VStack {
                    Spacer()
                    Text("It looks like this device doesn't support the DataScannerViewController")
                    Spacer()
                }
                .background(Color(UIColor.secondarySystemBackground))
            } else {
                VStack {
                    Spacer()
                    Text("It appears your camera may not be available")
                    Spacer()
                }
                .background(Color(UIColor.secondarySystemBackground))
            }
            HStack {
                Text("Scan: \(tempScanData), Symbology: \(tempScanSymbology)")
                    .padding()
                    .background(Color(UIColor.systemBackground).opacity(0.8))
                    .cornerRadius(8)

                Button("Insert") {
                    scannedData = tempScanData
                    scannedSymbology = tempScanSymbology
                    showScanner.toggle()
                }
                .padding()
                .background(Color(UIColor.systemBackground).opacity(0.8))
                .cornerRadius(8)
            }
            .padding(.bottom, 40)
//            .opacity(0.8)
        }
    }
}

#Preview {
    ScannerView(scannedData: .constant("asdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdf"), scannedSymbology: .constant("asdfasdf"), showScanner: .constant(true))
}
