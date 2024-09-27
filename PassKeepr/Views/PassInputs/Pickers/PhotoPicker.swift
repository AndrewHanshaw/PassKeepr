import CoreTransferable
import PhotosUI
import SwiftUI

struct PhotoPicker: View {
    @State private var photoItem: PhotosPickerItem?
    @Binding var selectedImage: Image
    @State private var showAlert: Bool = false
    private let alertTitleText = "Pass Icon"
    private let alertDescriptionText = "The pass icon is used to quickly identify the pass at a glance. It is shown in the top corner of the pass"

    var body: some View {
        Section {
            VStack {
                if selectedImage != Image("") {
                    HStack {
                        Spacer()
                        selectedImage
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                        Spacer()
                    }
                    Divider()
                }

                HStack {
                    Spacer()
                    PhotosPicker("Choose Icon Photo", selection: $photoItem, matching: .any(of: [.images, .not(.videos)]))
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
                        if let loaded = try? await photoItem?.loadTransferable(type: Image.self) {
                            selectedImage = loaded
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
    PhotoPicker(selectedImage: .constant(Image(systemName: "circle.plus.fill")))
}
