import UIKit
import Vision

func GetBarcodeFromImage(image: UIImage) -> (barcodeType: BarcodeType, payload: String)? {
    guard let cgImage = image.cgImage else { return nil }

    var result: (barcodeType: BarcodeType, payload: String)?

    let request = VNDetectBarcodesRequest { request, error in
        request.revision = VNDetectBarcodesRequestRevision3
        if let observations = request.results as? [VNBarcodeObservation], let firstObservation = observations.first {
            if let payload = firstObservation.payloadStringValue {
                // Detect a UPC-A barcode, which scans in with EAN13 symbology with a leading 0
                if firstObservation.symbology == VNBarcodeSymbology.ean13 && payload.count == 13 && payload.first == "0" {
                    result = (barcodeType: BarcodeType.upca, payload: String(payload.suffix(12)))

                } else {
                    result = (barcodeType: firstObservation.symbology.toBarcodeType() ?? BarcodeType.code128, payload: payload)
                }
            }
        } else if let error = error {
            print("Error detecting barcodes: \(error.localizedDescription)")
        }
    }

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    do {
        try handler.perform([request])
    } catch {
        print("Failed to perform barcode scan: \(error.localizedDescription)")
    }

    return result
}
