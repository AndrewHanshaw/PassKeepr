//
//  EditPass.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 1/3/24.
//

import SwiftUI

struct EditPass: View {
    @Binding var passObject: PassObject

    @State private var tempObject: PassObject

    init(passObject: Binding<PassObject>)
    {
        _passObject = passObject
        _tempObject = State(initialValue: passObject.wrappedValue)
    }

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            Form(){
                switch tempObject.passType {
                case PassType.identificationPass:
                    IdentificationInput(identificationInput:
                        Binding(
                            get: { tempObject.identificationString ?? "" },
                            set: { tempObject.identificationString = $0 }
                        )
                    )
                case PassType.barcodePass:
                    BarcodeInput(barcodeInput:
                        Binding(
                            get: { tempObject.barcodeString ?? "" },
                            set: { tempObject.barcodeString = $0 }
                        )
                    )
                case PassType.qrCodePass:
                    QRCodeInput(qrCodeInput:
                        Binding(
                            get: { tempObject.qrCodeString ?? "" },
                            set: { tempObject.qrCodeString = $0 }
                        ),
                      correctionLevel:
                                    Binding(
                                        get: { tempObject.qrCodeCorrectionLevel ?? QrCodeCorrectionLevel.medium },
                                        set: { tempObject.qrCodeCorrectionLevel = $0 }
                                    )
                    )
                case PassType.notePass:
                    NoteInput(noteInput:
                        Binding(
                            get: { tempObject.noteString ?? "" },
                            set: { tempObject.noteString = $0 }
                        )
                    )
                case PassType.businessCardPass:
                    BusinessCardInput(nameInput:
                        Binding(
                            get: { tempObject.name ?? "" },
                            set: { tempObject.name = $0 }
                        ),
                      titleInput:
                        Binding(
                            get: { tempObject.title ?? "" },
                            set: { tempObject.title = $0 }
                        ),
                      businessNameInput:
                        Binding(
                            get: { tempObject.businessName ?? "" },
                            set: { tempObject.businessName = $0 }
                        ),
                      phoneNumberInput:
                        Binding(
                            get: { tempObject.phoneNumber ?? "" },
                            set: { tempObject.phoneNumber = $0 }
                        ),
                      emailInput:
                        Binding(
                            get: { tempObject.email ?? "" },
                            set: { tempObject.email = $0 }
                        )
                    )
                case PassType.picturePass:
                    PictureInput()
                }
                Section {
                    Button(
                        action: {
                            passObject = tempObject
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
        .navigationTitle($tempObject.passName)
    }
}

#Preview {
    EditPass(passObject: .constant(PassObject(id: UUID(), passName: "Barcode Pass 1", passType: PassType.barcodePass, barcodeString: "1234", foregroundColor: 0xFF00FF, backgroundColor: 0xFFFFFF, textColor: 0x000000)))
}
