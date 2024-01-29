//
//  Barcode.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 11/20/23.
//

import SwiftUI

struct BarcodeView: View {
    var body: some View {
        let barcodeData = "Hello, Swift Barcode!"

        // Generate a 1D barcode image
        if let barcodeImage = GenerateBarcode(string: barcodeData,  viewWidth: UIScreen.main.bounds.width) {
            // Display the generated barcode image
            Image(uiImage: barcodeImage)
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    BarcodeView()
}
