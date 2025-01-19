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

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var isDocumentPickerPresented: Bool = false
    @State private var isInfoPagePresented: Bool = false
    @State private var showIcon = false
    @State private var width: CGSize = CGSizeZero

    var body: some View {
        VStack {
            Button(action: {
                modelData.deleteAllItems()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .foregroundColor(Color.red)
                        .padding(0)
                    Text("Delete All Passes")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color.white)
                        .padding(8)
                        .readSize(into: $width)
                }
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 2.0)
                    .onEnded { _ in
                        modelData.deleteAllItems()
                        modelData.deleteDataFile()
                        presentationMode.wrappedValue.dismiss()
                    }
            )
            .onTapGesture {
                modelData.deleteAllItems()
            }

            Button(action: {
                isInfoPagePresented.toggle()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .foregroundColor(Color(.secondarySystemFill))
                    Text("About")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .padding(8)
                        .frame(width: width.width)
                }
            }
            .background(RoundedRectangle(cornerRadius: 5)
                .foregroundColor(Color(.secondarySystemBackground))
            )
            .sheet(isPresented: $isInfoPagePresented, content: {
                About()
                    .presentationDragIndicator(.visible)
            })
        }
        .padding(10)
    }
}

#Preview {
    Settings()
        .environment(MockModelData())
}
