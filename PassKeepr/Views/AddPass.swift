//
//  AddPass.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 11/12/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImageDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.image] }

    var image: UIImage

    init(image: UIImage) {
        self.image = image
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        guard let loadedImage = UIImage(data: data) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.image = loadedImage
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = image.pngData() else {
            throw CocoaError(.fileWriteInapplicableStringEncoding)
        }
        return .init(regularFileWithContents: data)
    }
}

struct AddPass: View {
    @Environment(ModelData.self) var modelData

    @State private var passName: String = ""
    @State private var selectedPassType: PassType = .identificationPass
    @State private var identificationInput = ""
    @State private var barcodeInput = ""
    @State private var qrCodeInput = ""
    @State private var noteInput = ""
    @State private var nameInput = ""
    @State private var titleInput = ""
    @State private var businessNameInput = ""
    @State private var phoneNumberInput = ""
    @State private var emailInput = ""

    @Binding var isSheetPresented: Bool // Used to close the sheet in the parent view

    var image: UIImage?

    var body: some View {
        VStack {
            Form(){
                List {
                    Section {
                        Picker("Pass Type", selection: $selectedPassType) {
                            ForEach(PassType.allCases) { type in
                                HStack {
                                    Text(ListItemHelpers.GetStringSingular(type))
                                    Image(systemName: ListItemHelpers.GetSystemIcon(type))
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

                LabeledContent {
                    TextField(
                        "Name",
                        text: $passName
                    )
                } label : {
                    Text("Pass Name")
                }

                .disableAutocorrection(true)

                switch selectedPassType {
                    case PassType.identificationPass:
                        IdentificationInput(identificationInput: $identificationInput)
                    case PassType.barcodePass:
                        BarcodeInput(barcodeInput:$barcodeInput)
                    case PassType.qrCodePass:
                        QRCodeInput(qrCodeInput: $qrCodeInput)
                    case PassType.notePass:
                        NoteInput(noteInput: $noteInput)
                    case PassType.businessCardPass:
                        BusinessCardInput(nameInput: $nameInput, titleInput: $titleInput, businessNameInput: $businessNameInput, phoneNumberInput: $phoneNumberInput, emailInput: $emailInput)
                    case PassType.picturePass:
                        PictureInput()
                }

                Section {
                    Button(action: {isSheetPresented.toggle()},
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
                    Button(action: {
                                var addedPass = ListItem(id: UUID(), passName: passName, passType: selectedPassType)
                                switch addedPass.passType {
                                    case PassType.identificationPass:
                                        addedPass.identificationString = identificationInput
                                    case PassType.barcodePass:
                                        addedPass.barcodeString = barcodeInput
                                    case PassType.qrCodePass:
                                        addedPass.qrCodeString = qrCodeInput
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
                                modelData.listItems.append(addedPass)
                                modelData.encodeListItems()
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
                    )
                }
                .listRowBackground(Color.accentColor)
            }
        }
    }
}

#Preview {
    AddPass(isSheetPresented: .constant(true))
        .environment(ModelData(preview: true))
}
