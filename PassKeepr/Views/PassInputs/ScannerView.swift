import SwiftUI
import Vision
import VisionKit

struct ScannerView: View {
    @Binding var scannedData: String
    @Binding var scannedSymbology: VNBarcodeSymbology?
    @Binding var showScanner: Bool

    @State private var tempScanData = ""
    @State private var tempScanSymbology: VNBarcodeSymbology?

    var body: some View {
        ZStack(alignment: .bottom) {
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                CodeScanner(
                    shouldStartScanning: $showScanner,
                    scannedText: $tempScanData,
                    scannedSymbology: $tempScanSymbology,
                    dataToScanFor: [.barcode(symbologies: [.qr, .code128, .upce, .code39, .code93])]
                )
            } else if !DataScannerViewController.isSupported {
                VStack {
                    Spacer()
                    Text("This device doesn't support the DataScannerViewController")
                    Spacer()
                }
                .background(Color(UIColor.secondarySystemBackground))
            } else {
                VStack {
                    Spacer()
                    Text("Camera is not available")
                    Spacer()
                }
                .background(Color(UIColor.secondarySystemBackground))
            }
            HStack {
                Text("Scan: \(tempScanData), Symbology: \(tempScanSymbology?.rawValue ?? "-")")
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
    ScannerView(scannedData: .constant("asdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdf"), scannedSymbology: .constant(VNBarcodeSymbology.aztec), showScanner: .constant(true))
}
