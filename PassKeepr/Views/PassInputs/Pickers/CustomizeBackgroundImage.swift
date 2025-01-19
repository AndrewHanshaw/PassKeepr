import _PhotosUI_SwiftUI
import CoreImage
import SwiftUI

struct CustomizeBackgroundImage: View {
    @Binding var passObject: PassObject

    @State private var tempBackground: UIImage

    @State private var photoItem: PhotosPickerItem?

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(passObject: Binding<PassObject>) {
        _passObject = passObject
        _tempBackground = State(initialValue: UIImage(data: passObject.wrappedValue.backgroundImage)!)
    }

    var body: some View {
        Image(uiImage: tempBackground)
            .resizable()
            .scaledToFit()
            .padding(20)

        List {
            PhotosPicker("Change image", selection: $photoItem, matching: .any(of: [.images, .not(.videos)]))
                .frame(maxWidth: .infinity, alignment: .center)
                .onChange(of: photoItem) {
                    Task {
                        if let loaded = try? await photoItem?.loadTransferable(type: Data.self) {
                            tempBackground = UIImage(data: loaded)!
                        } else {
                            print("Failed")
                        }
                    }
                }

            Section {
                Button(
                    action: {
                        passObject.backgroundImage = tempBackground.pngData()!
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Save")
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
            }
            .listRowBackground(Color.accentColor)
        }
        .onChange(of: passObject.backgroundImage) {
            Task {
                if passObject.backgroundImage != Data() {
                    passObject.passStyle = PassStyle.eventTicket
                } else {
                    passObject.passStyle = PassStyle.generic
                }
            }
        }
    }
}

#Preview {
    CustomizeLogoImage(passObject: .constant(MockModelData().passObjects[0]))
}
