import CoreTransferable
import PhotosUI
import SwiftUI

struct LogoImagePicker: View {
    @State private var photoItem: PhotosPickerItem?
    @Binding var passObject: PassObject
    @State private var showAlert: Bool = false
    private let alertTitleText = "Pass Logo"
    private let alertDescriptionText = "The pass logo is a small image shown in the top left corner of the pass"

    @State private var isSheetPresented = false

    var body: some View {
        Section {
            // Display the image if it exsits (i.e. user has picked an image)
            if UIImage(data: passObject.logoImage) != nil {
                HStack {
                    Spacer()
                    Image(uiImage: UIImage(data: passObject.logoImage)!)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 150, alignment: .top)
                    Spacer()
                }
            }

            // Display the button that opens the photo picker
            ZStack {
                PhotosPicker("Choose Logo Image", selection: $photoItem, matching: .any(of: [.images, .not(.videos)]))
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack {
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
            }
            .onChange(of: photoItem) {
                Task {
                    if let loaded = try? await photoItem?.loadTransferable(type: Data.self) {
                        passObject.logoImage = UIImage(data: loaded)!.pngData()!
                    } else {
                        print("Failed")
                    }
                }
            }

            if passObject.logoImage != Data() {
                Button(action: { isSheetPresented.toggle() }, label: { Text("Customize") })
                    .frame(maxWidth: .infinity, alignment: .center)
                    .sheet(isPresented: $isSheetPresented) {
                        CustomizeLogoImage(passObject: $passObject)
                    }
            }
        }
    }
}

#Preview {
    LogoImagePicker(passObject: .constant(MockModelData().PassObjects[0]))
}
