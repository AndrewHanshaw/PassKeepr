import _PhotosUI_SwiftUI
import SwiftUI
import SwiftyCrop

struct CustomizeStripImage: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var passObject: PassObject
    @State private var tempStrip: UIImage?

    @State private var photoItem: PhotosPickerItem?
    @State private var imageForCrop: IdentifiableImage?

    @State private var showAlert: Bool = false

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(passObject: Binding<PassObject>) {
        _passObject = passObject
        _tempStrip = State(initialValue: UIImage(data: passObject.wrappedValue.stripImage))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Group {
                    if let strip = tempStrip {
                        Image(uiImage: strip)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: PassKitConstants.StripImage.height)
                            .clipped()
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                                .aspectRatio(PassKitConstants.StripImage.aspectRatio, contentMode: .fit)
                                .foregroundColor(Color.gray)
                                .opacity(0.5)
                            Text("Add a Strip Image")
                                .scaledToFit()
                                .textCase(nil)
                                .foregroundColor(Color.gray)
                                .opacity(0.7)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding([.top, .bottom], 20)

                PhotosPicker(selection: $photoItem, matching: .any(of: [.images, .not(.videos)])) {
                    Text(tempStrip == nil ? "Select a Strip Image" : "Change Strip Image")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(Color.white)
                        .padding(.vertical, 12)
                        .accentColorProminentButtonStyleIfAvailable()
                }
                .onChange(of: photoItem) {
                    Task {
                        if let loaded = try? await photoItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: loaded)
                        {
                            imageForCrop = IdentifiableImage(image: image)
                        } else {
                            print("Failed")
                        }
                    }
                }

                if tempStrip != nil {
                    Button(role: .destructive) {
                        passObject.stripImage = Data()
                        presentationMode.wrappedValue.dismiss()
                    }
                    label: {
                        Text("Remove Strip Image")
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
                    Text("Strip Image")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        if let strip = tempStrip {
                            passObject.stripImage = strip.pngData() ?? Data()
                            // Remove background image (incompatible with strip image)
                            passObject.backgroundImage = Data()
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
        }
        .sheetOrFullScreenCover(item: $imageForCrop) { item in
            SwiftyCropView(
                imageToCrop: item.image,
                maskShape: .rectangle,
                configuration: SwiftyCropConfiguration(
                    rectAspectRatio: PassKitConstants.StripImage.aspectRatio,
                    fonts: SwiftyCropConfiguration.Fonts(
                        interactionInstructions: Font.system(size: 16, weight: .bold, design: .rounded)
                    ),
                    colors: .appColors(colorScheme: colorScheme)
                )
            ) { croppedImage in
                tempStrip = croppedImage
            }
        }
    }
}

#Preview {
    CustomizeStripImage(passObject: .constant(MockModelData().passObjects[0]))
}
