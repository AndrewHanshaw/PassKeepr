import SwiftUI
import Vision
import VisionKit

struct CodeScanner: UIViewControllerRepresentable {
    @Binding var shouldStartScanning: Bool
    @Binding var scannedText: String
    @Binding var scannedBarcodeType: BarcodeType?

    var dataToScanFor: Set<DataScannerViewController.RecognizedDataType>

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: CodeScanner

        init(_ parent: CodeScanner) {
            self.parent = parent
        }

        func dataScanner(_: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case let .text(text):
                parent.scannedText = text.transcript

            case let .barcode(barcode):
                if let payload = barcode.payloadStringValue {
                    // Detect a UPC-A barcode, which scans in with EAN13 symbology with a leading 0
                    if barcode.observation.symbology == VNBarcodeSymbology.ean13 && payload.count == 13 && payload.first == "0" {
                        parent.scannedText = String(payload.suffix(12))
                        parent.scannedBarcodeType = BarcodeType.upca
                    } else {
                        parent.scannedText = payload
                        parent.scannedBarcodeType = barcode.observation.symbology.toBarcodeType()
                    }
                }

            default:
                print("unexpected item")
            }
        }
    }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let dataScannerVC = DataScannerViewController(
            recognizedDataTypes: dataToScanFor,
            qualityLevel: .accurate,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )

        dataScannerVC.delegate = context.coordinator

        return dataScannerVC
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context _: Context) {
        if shouldStartScanning {
            try? uiViewController.startScanning()
        } else {
            uiViewController.stopScanning()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
