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
    @EnvironmentObject var modelData: ModelData

    @State private var isDocumentPickerPresented: Bool = false
    @State private var showIcon = false

    var body: some View {
        Form {
            Section {
                Button("Delete All Passes", role: .destructive) {
                    modelData.deleteAllItems()
                }
                Button("Delete Data File", role: .destructive) {
                    modelData.deleteDataFile()
                }
                Button(action: {
                    showIcon = true
                }) {
                    Text("Show App Icon")
                }
                .sheet(isPresented: $showIcon) {
                    VStack {
                        Spacer()
                        AppIcon()
                        Spacer()
                    }
                }

                let uiimage = ImageRenderer(content: AppIcon().frame(width: 1024, height: 1024)).uiImage!

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
