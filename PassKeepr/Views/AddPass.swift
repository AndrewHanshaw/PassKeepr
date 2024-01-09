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
    @State private var isDocumentPickerPresented: Bool = false

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
                    TextField("Barcode Number", text: $barcodeNumber)
                        .keyboardType(.numberPad)
                }
                else if selectedPassType == PassType.qrCodePass {
                    TextField("QR Code Input", text: $qrCodeInput)
                }
                else if selectedPassType == PassType.notePass {
                    TextField("Note", text: $noteInput)
                }

            }
            Button ("Add Pass") {
                modelData.listItems.append(addedPass)
                encode(filename, modelData.listItems)
            }
            Button ("Delete All Passes") {
                deleteAllItems(filename: filename)
            }
            Button ("Delete Data File") {
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

            Spacer()
        }
    }
}

#Preview {
    AddPass()
        .environment(ModelData())
}
