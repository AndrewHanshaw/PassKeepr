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
                VStack(alignment: .center) {
                    Text("This device doesn't support the DataScannerViewController")
                }
                .background(Color(UIColor.secondarySystemBackground))
            } else {
                VStack(alignment: .center) {
                    Text("Camera is not available")
                }
                .background(Color(UIColor.secondarySystemBackground))
            }
            VStack(spacing: 20) {
                var displayedString: String {
                    if tempScanData.isEmpty || (tempScanBarcodeType == nil) {
                        return "Tap a highlighted barcode to select it"
                    } else {
                        if let symbologyDescription = tempScanBarcodeType?.description {
                            return "\(tempScanData)\n\(symbologyDescription)"
                        } else {
                            return "-"
                        }
                    }
                }

                if #available(iOS 26.0, *) {
                    Text(displayedString)
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                        .padding()
                        .glassEffect()
                        .id(displayedString)
                        .transition(.opacity)
                        .animation(.smooth, value: displayedString)
                } else {
                    // Fallback on earlier versions
                }

                Button("Insert") {
                    scannedData = tempScanData
                    scannedBarcodeType = tempScanBarcodeType
                    showScanner.toggle()
                }
                .font(.system(size: 18))
                .controlSize(.large)
                .glassProminentButtonStyleIfAvailable()
            }
            .padding(.bottom, 100)
        }
    }
}

#Preview {
    ScannerView(scannedData: .constant("asdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdf"), scannedBarcodeType: .constant(BarcodeType.code39), showScanner: .constant(true))
}
