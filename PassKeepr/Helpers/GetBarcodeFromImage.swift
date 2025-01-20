import UIKit
import Vision

func GetBarcodeFromImage(image: UIImage) -> (symbology: VNBarcodeSymbology, payload: String)? {
    guard let cgImage = image.cgImage else { return nil }

    var result: (symbology: VNBarcodeSymbology, payload: String)?

    let request = VNDetectBarcodesRequest { request, error in
        request.revision = VNDetectBarcodesRequestRevision3
        if let observations = request.results as? [VNBarcodeObservation], let firstObservation = observations.first {
            if let payload = firstObservation.payloadStringValue {
                result = (symbology: firstObservation.symbology, payload: payload)
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
