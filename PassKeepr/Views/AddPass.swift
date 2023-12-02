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
    @State private var selectedPassType: passType = .identificationPass
    @State private var barcodeNumber = "0"
    @State private var isDocumentPickerPresented: Bool = false

    var addedPass = ListItem(id: UUID(), passName: "added pass", passType: PassType.barcodePass)

    var image: UIImage?

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
            Button ("Delete All Passes") {
                deleteAllItems()
            }
            Button ("Delete Data File") {
                deleteDataFile()
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
