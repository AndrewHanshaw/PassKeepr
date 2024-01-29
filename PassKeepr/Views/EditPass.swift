//
//  EditPass.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 1/3/24.
//

import SwiftUI

struct EditPass: View {
    @Binding var passObject: PassObject

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            Form(){
                switch passObject.passType {
                case PassType.identificationPass:
                    IdentificationInput(identificationInput:
                        Binding(
                            get: { passObject.identificationString ?? "" },
                            set: { passObject.identificationString = $0 }
                        )
                    )
                case PassType.barcodePass:
                    BarcodeInput(barcodeInput:
                        Binding(
                            get: { passObject.barcodeString ?? "" },
                            set: { passObject.barcodeString = $0 }
                        )
                    )
                case PassType.qrCodePass:
                    QRCodeInput(qrCodeInput:
                        Binding(
                            get: { passObject.qrCodeString ?? "" },
                            set: { passObject.qrCodeString = $0 }
                        )
                    )
                case PassType.notePass:
                    NoteInput(noteInput:
                        Binding(
                            get: { passObject.noteString ?? "" },
                            set: { passObject.noteString = $0 }
                        )
                    )
                case PassType.businessCardPass:
                    BusinessCardInput(nameInput:
                        Binding(
                            get: { passObject.name ?? "" },
                            set: { passObject.name = $0 }
                        ),
                      titleInput:
                        Binding(
                            get: { passObject.title ?? "" },
                            set: { passObject.title = $0 }
                        ),
                      businessNameInput:
                        Binding(
                            get: { passObject.businessName ?? "" },
                            set: { passObject.businessName = $0 }
                        ),
                      phoneNumberInput:
                        Binding(
                            get: { passObject.phoneNumber ?? "" },
                            set: { passObject.phoneNumber = $0 }
                        ),
                      emailInput:
                        Binding(
                            get: { passObject.email ?? "" },
                            set: { passObject.email = $0 }
                        )
                    )
                case PassType.picturePass:
                    PictureInput()
                }
                Section {
                    Button(
                        action: {
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
        .navigationTitle($passObject.passName)
    }
}

#Preview {
    EditPass(passObject: .constant(PassObject(id: UUID(), passName: "Barcode Pass 1", passType: PassType.barcodePass, barcodeString: "1234", foregroundColor: 0xFF00FF, backgroundColor: 0xFFFFFF, textColor: 0x000000)))
}
