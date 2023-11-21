//
//  AddPass.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 11/12/23.
//

import SwiftUI

struct AddPass: View {
    @Environment(ModelData.self) var modelData
    
    @State private var passName: String = ""
    @State private var selectedPassType: passType = .identificationPass
    @State private var barcodeNumber = "0"

    var addedPass = ListItem(id: 1, name: "added pass", type: passType.barcodePass)

    var body: some View {
        VStack {
            Form(){
                List {
                    Picker("Pass Type", selection: $selectedPassType) {
                        Text("ID Card").tag(passType.identificationPass)
                        Text("Barcode Pass").tag(passType.barcodePass)
                        Text("QR Code Pass").tag(passType.barcodePass)
                        Text("Notecard").tag(passType.notePass)
                        Text("Business Card").tag(passType.businessCardPass)
                        Text("Picture Pass").tag(passType.picturePass)
                    }
                }

                TextField(
                    "Pass Name",
                    text: $passName
                )
                .disableAutocorrection(true)

                if selectedPassType == passType.barcodePass {
                    TextField(
                        "Barcode Number",
                        text: $barcodeNumber
                    )
                    .keyboardType(.numberPad)
                }

            }
            Button ("Add Pass") {
                modelData.listItems.append(addedPass)
                encode("data2.json", modelData.listItems)
            }

            Spacer()
        }
    }
}

#Preview {
    AddPass()
        .environment(ModelData())
}
