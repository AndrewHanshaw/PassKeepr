import CoreTransferable
import PhotosUI
import SwiftUI

struct BackgroundImagePicker: View {
    @State private var photoItem: PhotosPickerItem?
    @Binding var passObject: PassObject
    @State private var selectedImage: UIImage = .init()
    @State private var showAlert: Bool = false
    private let alertTitleText = "Background Image"
    private let alertDescriptionText = "The background image is displayed behind the pass. The image will be blurred. It is only available for code 128 barcode passes and qr code passes"

    var body: some View {
        Section {
            VStack {
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

                HStack {
                    Spacer()
                    PhotosPicker("Choose Background Image", selection: $photoItem, matching: .any(of: [.images, .not(.videos)]))
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

                            selectedImage = resizeImage(image: selectedImage, targetSize: CGSize(width: 224, height: 284))!

                            passObject.backgroundImage = selectedImage.pngData()!
                        } else {
                            print("Failed")
                        }
                    }
                }
            }
        }
    }
}

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
    let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage!
}

#Preview {
    BackgroundImagePicker(passObject: .constant(MockModelData().PassObjects[0]))
}
