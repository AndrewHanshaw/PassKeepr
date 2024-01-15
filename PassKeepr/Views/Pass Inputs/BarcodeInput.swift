//
//  BarcodeInput.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 1/10/24.
//

import SwiftUI

struct BarcodeInput: View {
    @Binding var barcodeInput: String

    var body: some View {
        Section {
            LabeledContent {
                TextField("Barcode Number", text: $barcodeInput)
                    .keyboardType(.numberPad)
            } label : {
                Text("Number")
            }
        }
    }
}

#Preview {
    BarcodeInput(barcodeInput:.constant("Test Barcode"))
}
