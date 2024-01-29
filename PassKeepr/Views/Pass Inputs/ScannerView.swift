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
    @Binding var showScanner: Bool

    @State private var tempScanData = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                DataScannerRepresentable(
                    shouldStartScanning: $showScanner,
                    scannedText: $tempScanData,
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
                Text("Scan: \(tempScanData)")
                    .padding()
                    .background(Color(UIColor.systemBackground).opacity(0.8))
                    .cornerRadius(8)

                Button("Insert") {
                    scannedData = tempScanData
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
    ScannerView(scannedData: .constant("asdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdf"), showScanner: .constant(true))
}
