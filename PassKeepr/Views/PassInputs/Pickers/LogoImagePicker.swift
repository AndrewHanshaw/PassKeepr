import CoreTransferable
import PhotosUI
import SwiftUI

struct LogoImagePicker: View {
    @State private var photoItem: PhotosPickerItem?
    @Binding var passObject: PassObject
    @State private var selectedImage: UIImage = .init()
    @State private var showAlert: Bool = false
    private let alertTitleText = "Pass Logo"
    private let alertDescriptionText = "The pass logo is used to quickly identify the pass at a glance. It is shown in the top corner of the pass"

    var body: some View {
        Section {
            VStack {
                // Display the image if it exsits (i.e. user has picked an image)
                if selectedImage != UIImage() {
                    HStack {
                        Spacer()
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                        Spacer()
                    }
                    Divider()
                }

                // Display the button that opens the photo picker
                HStack {
                    Spacer()
                    PhotosPicker("Choose Logo Image", selection: $photoItem, matching: .any(of: [.images, .not(.videos)]))
                    Spacer()
                    Button(
                        action: {
                            showAlert.toggle()
                        },
                        label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(Color(.secondaryLabel))
                        }
                    )
                    .buttonStyle(PlainButtonStyle())
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text(alertTitleText),
                              message: Text(alertDescriptionText),
                              dismissButton: .default(Text("OK")))
                    }
                }
                .onChange(of: photoItem) {
                    Task {
                        if let loaded = try? await photoItem?.loadTransferable(type: Data.self) {
                            selectedImage = UIImage(data: loaded)!

                            selectedImage = selectedImage.resizeToFit()

                            passObject.logoImage = selectedImage.pngData()!
                        } else {
                            print("Failed")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    LogoImagePicker(passObject: .constant(MockModelData().PassObjects[0]))
}
