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

    let filename = "PassKeeprData.json"

    var image: UIImage?

    var body: some View {
        VStack {
            Form(){
                List {
                    Section {
                        Picker("Pass Type", selection: $selectedPassType) {
                            Text("QR Code Pass").tag(PassType.qrCodePass)
                            Text("ID Card").tag(PassType.identificationPass)
                            Text("Barcode Pass").tag(PassType.barcodePass)
                            Text("Notecard").tag(PassType.notePass)
                            Text("Business Card").tag(PassType.businessCardPass)
                            Text("Picture Pass").tag(PassType.picturePass)
                        }
                    }
                }

                TextField(
                    "Pass Name",
                    text: $passName
                )
                .disableAutocorrection(true)

                if selectedPassType == PassType.barcodePass {
                    Section {
                        TextField("Barcode Number", text: $barcodeInput)
                            .keyboardType(.numberPad)
                    }
                }
                if selectedPassType == PassType.identificationPass {
                    Section {
                        TextField("ID Text", text: $identificationInput)
                    }
                }
                else if selectedPassType == PassType.qrCodePass {
                    Section {
                        TextField("QR Code Input", text: $qrCodeInput)
                    }
                }
                else if selectedPassType == PassType.notePass {
                    Section {
                        TextField("Note", text: $noteInput)
                    } footer: {Text("Notes should be less than XXX characters")
                    }
                }
                else if selectedPassType == PassType.businessCardPass {
                    Section {
                        TextField("Name", text: $nameInput)
                        TextField("Title (optional)", text: $titleInput)
                        TextField("Business Name (optional)", text: $businessNameInput)
                        TextField("Phone Number (optional)", text: $phoneNumberInput)
                        TextField("Email (optional)", text: $emailInput)
                    }
                }
                else if selectedPassType == PassType.picturePass {
                    Section {
                        Text("placeholder")
                    } footer: {Text("Images should have a ratio of X:X, and be at least X dpi (XXX x XXXpx)")
                    }
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
                                encode(filename, modelData.listItems)
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

            Spacer()
        }
    }
}

#Preview {
    AddPass(isSheetPresented: .constant(true))
        .environment(ModelData(preview: true))
}
