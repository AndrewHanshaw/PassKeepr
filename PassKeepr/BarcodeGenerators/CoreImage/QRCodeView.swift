//
//  QRCodeView.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 11/22/23.
//

import SwiftUI

struct QRCodeView: View {
    var data: String
    var correctionLevel: QrCodeCorrectionLevel

    var body: some View {
        if let QRCodeImage = GenerateQRCode(string: data, viewWidth: UIScreen.main.bounds.width, correctionLevel: correctionLevel) {
            Image(uiImage: QRCodeImage)
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    QRCodeView(data: "Hello, Swift QRcode!", correctionLevel: QrCodeCorrectionLevel.high)
}
