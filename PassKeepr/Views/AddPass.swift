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
    @State private var barcodeNumber = ""
    @State private var qrCodeInput = ""
    @State private var noteInput = ""
    @State private var nameInput = ""
    @State private var titleInput = ""
    @State private var businessNameInput = ""
    @State private var phoneNumberInput = ""
    @State private var emailInput = ""
    @State private var isDocumentPickerPresented: Bool = false

    @Binding var isSheetPresented: Bool // Used to close the sheet in the parent view

    var addedPass = ListItem(id: UUID(), passName: "added pass", passType: PassType.barcodePass)

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
                        TextField("Barcode Number", text: $barcodeNumber)
                            .keyboardType(.numberPad)
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

                Button ("Delete All Passes", role: .destructive) {
                    deleteAllItems(filename: filename)
                }

                Button ("Delete Data File", role: .destructive) {
                    deleteDataFile(filename: filename)
                }

                let iconView = AppIcon().frame(width: 1024, height: 1024)
                let cgImage = ImageRenderer(content: iconView).cgImage!
                let uiimage = UIImage(cgImage: cgImage)
                Button ("Save Icon image") {
                    self.isDocumentPickerPresented.toggle()
                }
                .fileExporter(isPresented: $isDocumentPickerPresented, document: ImageDocument(image: uiimage), contentType: .image, defaultFilename: "iconImage.png") { result in
                    // Handle export result if needed
                    if case .success = result {
                        print("Image saved successfully.")
                    }
                }
            }

            Spacer()
        }
    }
}

#Preview {
    AddPass(isSheetPresented: .constant(true))
        .environment(ModelData())
}
