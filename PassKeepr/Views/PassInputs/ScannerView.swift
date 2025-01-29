import SwiftUI
import Vision
import VisionKit

struct ScannerView: View {
    @Binding var scannedData: String
    @Binding var scannedBarcodeType: BarcodeType?
    @Binding var showScanner: Bool

    @State private var tempScanData = ""
    @State private var tempScanBarcodeType: BarcodeType?

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
                    if tempScanData.isEmpty || (tempScanBarcodeType == nil) {
                        return "Tap a highlighted barcode to select it"
                    } else {
                        if let symbologyDescription = tempScanBarcodeType?.description {
                            return "Scanned Data: \(tempScanData)\nType: \(symbologyDescription)"
                        } else {
                            return "-"
                        }
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
                        scannedBarcodeType = tempScanBarcodeType
                        showScanner.toggle()
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground).opacity(0.8))
                    .cornerRadius(8)
                    Spacer()
                }
            }
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    ScannerView(scannedData: .constant("asdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdf"), scannedBarcodeType: .constant(BarcodeType.code39), showScanner: .constant(true))
}
