//
//  EditPass.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 1/3/24.
//

import SwiftUI

struct EditPass: View {
    @Binding var listItem: ListItem

    var body: some View {
        VStack {
            Form(){
                TextField("Pass Name", text: $listItem.passName)
                .disableAutocorrection(true)

                if listItem.passType == PassType.barcodePass {
                    TextField("Barcode Number", text: Binding(
                        get: { listItem.barcodeString ?? "" },
                        set: { listItem.barcodeString = $0.isEmpty ? nil : $0 }
                    ))	
                    .keyboardType(.numberPad)
                }
                else if listItem.passType == PassType.qrCodePass {
                    TextField("QR Code Input", text: Binding(
                        get: { listItem.qrCodeString ?? "" },
                        set: { listItem.qrCodeString = $0 }
                        )
                    )
                }
                else if listItem.passType == PassType.notePass {
                    TextField("Note", text: Binding(
                        get: { listItem.noteString ?? "" },
                        set: { listItem.noteString = $0 }
                        ))
                }
                Section {
                    Button(action: {
                        //isSheetPresented = false
                    },
                   label: {
                        HStack {
                          Spacer()
                          Text("Save")
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                          Spacer()
                        }
                    }
                    )
                }
                .listRowBackground(Color.accentColor)
            }
        }
    }
}

#Preview {
    EditPass(listItem:.constant(ListItem(id: UUID(), passName: "Barcode Pass 1", passType: PassType.barcodePass, barcodeString: "1234")))
}
