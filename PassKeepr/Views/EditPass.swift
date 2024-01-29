//
//  EditPass.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 1/3/24.
//

import SwiftUI

struct EditPass: View {
    @Binding var listItem: ListItem

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            Form(){
                switch listItem.passType {
                case PassType.identificationPass:
                    IdentificationInput(identificationInput:
                        Binding(
                            get: { listItem.identificationString ?? "" },
                            set: { listItem.identificationString = $0 }
                        )
                    )
                case PassType.barcodePass:
                    BarcodeInput(barcodeInput:
                        Binding(
                            get: { listItem.barcodeString ?? "" },
                            set: { listItem.barcodeString = $0 }
                        )
                    )
                case PassType.qrCodePass:
                    QRCodeInput(qrCodeInput:
                        Binding(
                            get: { listItem.qrCodeString ?? "" },
                            set: { listItem.qrCodeString = $0 }
                        )
                    )
                case PassType.notePass:
                    NoteInput(noteInput:
                        Binding(
                            get: { listItem.noteString ?? "" },
                            set: { listItem.noteString = $0 }
                        )
                    )
                case PassType.businessCardPass:
                    BusinessCardInput(nameInput:
                        Binding(
                            get: { listItem.name ?? "" },
                            set: { listItem.name = $0 }
                        ),
                      titleInput:
                        Binding(
                            get: { listItem.title ?? "" },
                            set: { listItem.title = $0 }
                        ),
                      businessNameInput:
                        Binding(
                            get: { listItem.businessName ?? "" },
                            set: { listItem.businessName = $0 }
                        ),
                      phoneNumberInput:
                        Binding(
                            get: { listItem.phoneNumber ?? "" },
                            set: { listItem.phoneNumber = $0 }
                        ),
                      emailInput:
                        Binding(
                            get: { listItem.email ?? "" },
                            set: { listItem.email = $0 }
                        )
                    )
                case PassType.picturePass:
                    PictureInput()
                }
                Section {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
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
        .navigationTitle($listItem.passName)
    }
}

#Preview {
    EditPass(listItem:.constant(ListItem(id: UUID(), passName: "Barcode Pass 1", passType: PassType.barcodePass, barcodeString: "1234")))
}
