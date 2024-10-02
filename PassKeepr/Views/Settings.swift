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
        image = loadedImage
    }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        guard let data = image.pngData() else {
            throw CocoaError(.fileWriteInapplicableStringEncoding)
        }
        return .init(regularFileWithContents: data)
    }
}

struct Settings: View {
    @Environment(ModelData.self) var modelData

    @State private var isDocumentPickerPresented: Bool = false

    var body: some View {
        Form {
            Section {
                Button("Delete All Passes", role: .destructive) {
                    modelData.deleteAllItems()
                }
                Button("Delete Data File", role: .destructive) {
                    modelData.deleteDataFile()
                }
                let iconView = AppIcon().frame(width: 1024, height: 1024)
                let cgImage = ImageRenderer(content: iconView).cgImage!
                let uiimage = UIImage(cgImage: cgImage)
                Button("Save Icon image") {
                    self.isDocumentPickerPresented.toggle()
                }
                .fileExporter(isPresented: $isDocumentPickerPresented, document: ImageDocument(image: uiimage), contentType: .image, defaultFilename: "iconImage.png") { result in
                    if case .success = result {
                        print("Image saved successfully.")
                    }
                }
            } footer: { Text("PassKeepr. Created by Drew Hanshaw")
            }
        }
    }
}

#Preview {
    Settings()
        .environment(MockModelData())
}
