//
//  QRCodeInput.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 1/10/24.
//

import SwiftUI

struct QRCodeInput: View {
    @Binding var qrCodeInput: String

    var body: some View {
        Section {
            LabeledContent {
                TextField("Data", text: $qrCodeInput)
            } label : {
                Text("Payload")
            }
        }
    }
}

#Preview {
    QRCodeInput(qrCodeInput:.constant("Test QR Code"))
}
