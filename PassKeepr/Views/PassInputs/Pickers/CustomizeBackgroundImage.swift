import _PhotosUI_SwiftUI
import CoreImage
import SwiftUI

struct CustomizeBackgroundImage: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var passObject: PassObject

    @State private var tempBackground: UIImage?

    @State private var photoItem: PhotosPickerItem?

    @State private var showAlert: Bool = false
    private let alertTitleText = "Background Image"
    private let alertDescriptionText = "The background image is displayed behind the pass. The image will be blurred.\nOnly available for passes without barcodes, or passes with Code 128, PDF417, or QR CodeX barcodes"

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(passObject: Binding<PassObject>) {
        _passObject = passObject
        _tempBackground = State(initialValue: UIImage(data: passObject.wrappedValue.backgroundImage))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let tempBackground {
                    HStack {
                        Spacer()
                        Image(uiImage: tempBackground)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .padding(20)
                        Spacer()
                    }
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                            .aspectRatio(1 / 1.45, contentMode: .fit)
                            .frame(maxHeight: 300)
                            .foregroundColor(Color.gray)
                            .opacity(0.5)
                        Text("Add a Background Image")
                            .foregroundColor(Color.gray)
                            .opacity(0.7)
                    }
                    .padding([.top, .bottom], 20)
                    .frame(maxWidth: .infinity, alignment: .center)
                }

                ZStack {
                    PhotosPicker(tempBackground == nil ? "Select a Background Image" : "Change Background Image", selection: $photoItem, matching: .any(of: [.images, .not(.videos)]))
                        .foregroundColor(Color.white)
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
                        Image(systemName: "info.circle")
                            .foregroundColor(Color.white)
                            .onTapGesture {
                                showAlert.toggle()
                            }
                            .alert(isPresented: $showAlert) {
                                Alert(title: Text(alertTitleText),
                                      message: Text(alertDescriptionText),
                                      dismissButton: .default(Text("OK")))
                            }
                            .padding(.trailing, 12)
                    }
                }
                .padding([.top, .bottom], 12)
                .accentColorProminentButtonStyleIfAvailable()

                if tempBackground != nil {
                    Button(role: .destructive) {
                        passObject.backgroundImage = Data()
                        presentationMode.wrappedValue.dismiss()
                    }
                    label: {
                        Text("Remove Background Image")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding([.top, .bottom], 12)
                    .listSectionBackgroundModifier()
                }

                Spacer()
            }
            .padding()
            .background(colorScheme == .light ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Background Image")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        if let background = tempBackground {
                            passObject.backgroundImage = background.resize(targetSize: CGSize(width: 112, height: 142))!.pngData()!
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .toolbarConfirmButtonModifier()
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .toolbarCancelButtonModifier()
                }
            }
            .onChange(of: passObject.backgroundImage) {
                if passObject.backgroundImage != Data() {
                    // Force white text when a background color is set
                    passObject.foregroundColor = Color.white.toHex()
                }
            }
        }
    }

    func scaleImage(image: UIImage, scalePercent: CGFloat) -> UIImage? {
        // Calculate the target size based on the scale percentage
        let targetSize = CGSize(
            width: image.size.width * scalePercent,
            height: image.size.height * scalePercent
        )

        // Ensure we have a valid renderer
        let renderer = ImageRenderer(content: Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: targetSize.width, height: targetSize.height))

        // Render the scaled-down image
        renderer.scale = UIScreen.main.scale // Maintain screen scale for quality
        return renderer.uiImage
    }
}

#Preview {
    CustomizeBackgroundImage(passObject: .constant(MockModelData().passObjects[0]))
}
