import _PhotosUI_SwiftUI
import CoreImage
import SwiftUI

struct CustomizeBackgroundImage: View {
    @Binding var passObject: PassObject

    @State private var tempBackground: UIImage?

    @State private var photoItem: PhotosPickerItem?

    @State private var showAlert: Bool = false
    private let alertTitleText = "Background Image"
    private let alertDescriptionText = "The background image is displayed behind the pass. The image will be blurred. (Only available for code 128 barcode and QR Code passes)"

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(passObject: Binding<PassObject>) {
        _passObject = passObject
        _tempBackground = State(initialValue: UIImage(data: passObject.wrappedValue.backgroundImage))
    }

    var body: some View {
        List {
            Section {
                ZStack {
                    PhotosPicker("Choose Background Image", selection: $photoItem, matching: .any(of: [.images, .not(.videos)]))
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
            }
            header: {
                if let background = tempBackground {
                    Image(uiImage: background)
                        .resizable()
                        .scaledToFit()
                        .padding(20)
                }
            }

            Section {
                Button(role: .destructive) {
                    passObject.backgroundImage = Data()
                    presentationMode.wrappedValue.dismiss()
                }
                label: {
                    Text("Remove Background Image")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }

            Section {
                Button(
                    action: {
                        if let background = tempBackground {
                            passObject.backgroundImage = background.pngData()!
                        }
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
    CustomizeLogoImage(passObject: .constant(MockModelData().passObjects[0]), placeholderColor: Color.black)
}
