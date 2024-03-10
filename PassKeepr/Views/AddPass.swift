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
    @State private var selectedPassType: PassType = .identificationPass
    @State private var identificationInput = ""
    @State private var barcodeString = ""
    @State private var barcodeType = BarcodeType.code39
    @State private var qrCodeInput = ""
    @State private var qrCodeCorrectionLevel = QrCodeCorrectionLevel.medium
    @State private var noteInput = ""
    @State private var nameInput = ""
    @State private var titleInput = ""
    @State private var businessNameInput = ""
    @State private var phoneNumberInput = ""
    @State private var emailInput = ""
    @State private var foregroundColorInput = Color(hex:0x000000)
    @State private var backgroundColorInput = Color(hex:0x000000)
    @State private var textColorInput = Color(hex:0x000000)
    @State private var iconImage = Image("")

    @Binding var isSheetPresented: Bool // Used to close the sheet in the parent view

    var image: UIImage?

    var body: some View {
        VStack {
            Form(){
                List {
                    Section {
                        LabeledContent {
                            TextField(
                                "Name",
                                text: $passName
                            )
                        } label : {
                            Text("Pass Name")
                        }
                        .disableAutocorrection(true)

                        Picker("Pass Type", selection: $selectedPassType) {
                            ForEach(PassType.allCases) { type in
                                HStack {
                                    Text(PassObjectHelpers.GetStringSingular(type))
                                    Image(systemName: PassObjectHelpers.GetSystemIcon(type))
                                }.tag(type)
                            }
                        }
                    } header: {
                        Text("Add a Pass:")
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                            .textCase(nil)
                            .padding([.bottom])
                    }
                }

                switch selectedPassType {
                    case PassType.identificationPass:
                        IdentificationInput(identificationInput: $identificationInput)
                    case PassType.barcodePass:
                        BarcodeInput(barcodeInput: $barcodeString, barcodeType: $barcodeType)
                    case PassType.qrCodePass:
                        QRCodeInput(qrCodeInput: $qrCodeInput, correctionLevel: $qrCodeCorrectionLevel)
                    case PassType.notePass:
                        NoteInput(noteInput: $noteInput)
                    case PassType.businessCardPass:
                        BusinessCardInput(nameInput: $nameInput, titleInput: $titleInput, businessNameInput: $businessNameInput, phoneNumberInput: $phoneNumberInput, emailInput: $emailInput)
                    case PassType.picturePass:
                        PictureInput()
                } // Switch

                ColorInput(bgColor: $foregroundColorInput, fgColor: $backgroundColorInput, textColor: $textColorInput)

                Section {
                    Button(
                        action: {
                            isSheetPresented.toggle()
                        },
                        label: {
                            HStack {
                                Spacer()
                                Text("Preview Pass")
                                Spacer()
                        }
                    }
                    )
                }

                Section {
                    Button(
                        action: {
                            var addedPass = PassObject(id: UUID(), passName: passName, passType: selectedPassType, foregroundColor: foregroundColorInput.toHex(), backgroundColor: backgroundColorInput.toHex(), textColor: textColorInput.toHex())
                            switch addedPass.passType {
                                case PassType.identificationPass:
                                    addedPass.identificationString = identificationInput
                                case PassType.barcodePass:
                                    addedPass.barcodeString = barcodeString
                                    addedPass.barcodeType = barcodeType
                                case PassType.qrCodePass:
                                    addedPass.qrCodeString = qrCodeInput
                                    addedPass.qrCodeCorrectionLevel = qrCodeCorrectionLevel
                                case PassType.notePass:
                                    addedPass.noteString = noteInput
                                case PassType.businessCardPass:
                                    addedPass.name = nameInput
                                    addedPass.title = titleInput
                                    addedPass.businessName = businessNameInput
                                    addedPass.phoneNumber = phoneNumberInput
                                    addedPass.email = emailInput
                                case PassType.picturePass:
                                    addedPass.pictureID = emailInput // Placeholder
                            }
                            modelData.PassObjects.append(addedPass)
                            modelData.encodePassObjects()
                            isSheetPresented.toggle()
                        },
                       label: {
                            HStack {
                              Spacer()
                              Text("Add Pass")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                              Spacer()
                            }
                        }
                    ) // Button
                } // Section
                .listRowBackground(Color.accentColor)
            } // Form
        } // VStack
        .scrollDismissesKeyboard(.immediately)
    } // View
} // Struct

#Preview {
    AddPass(isSheetPresented: .constant(true))
        .environment(ModelData(preview: true))
}
