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
                    scannedBarcodeType: $tempScanBarcodeType,
                    dataToScanFor: [.barcode(symbologies: [.qr, .code128, .upce, .ean13, .code39, .code93])]
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
            VStack {
                var displayedString: String {
                    if tempScanData.isEmpty || (tempScanSymbology?.rawValue.isEmpty ?? true) {
                        return "Tap a highlighted barcode to select it"
                    } else {
                        let symbologyDescription = tempScanSymbology?.toBarcodeType()?.description ?? "-"
                        return "Scanned Data: \(tempScanData)\nType: \(symbologyDescription)"
                    }
                }

                Text(displayedString)
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(UIColor.systemBackground).opacity(0.8))
                    .cornerRadius(8)

                HStack {
                    Spacer()
                    Button("Insert") {
                        scannedData = tempScanData
                        scannedSymbology = tempScanSymbology
                        showScanner.toggle()
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground).opacity(0.8))
                    .cornerRadius(8)
                    Spacer()
                }
            }
            .padding(.bottom, 40)
//            .opacity(0.8)
        }
        .onChange(of: tempScanData) {
            print(tempScanData)
            print(tempScanSymbology?.toBarcodeType()?.description)
        }
    }
}

#Preview {
    ScannerView(scannedData: .constant("asdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdf"), scannedSymbology: .constant(VNBarcodeSymbology.aztec), showScanner: .constant(true))
}
