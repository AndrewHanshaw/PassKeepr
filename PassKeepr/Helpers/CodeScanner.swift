import SwiftUI
import VisionKit

struct CodeScanner: UIViewControllerRepresentable {
    @Binding var shouldStartScanning: Bool
    @Binding var scannedText: String
    @Binding var scannedSymbology: String

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
                parent.scannedText = barcode.payloadStringValue ?? "Unable to decode the scanned code"
                parent.scannedSymbology = barcode.observation.symbology.rawValue
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
