import _PhotosUI_SwiftUI
import CoreImage
import SwiftUI
import SwiftyCrop

struct CustomizeBackgroundImage: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @Binding var passObject: PassObject

    @State private var tempBackground: UIImage?

    @State private var photoItem: PhotosPickerItem?
    @State private var imageForCrop: IdentifiableImage?
    @State private var isPhotoPickerPresented = false
    @State private var isCameraPresented = false

    @State private var showAlert: Bool = false
    private let alertTitleText = "Background Image"
    private let alertDescriptionText = "The background image is displayed behind the pass. The image will be blurred.\nOnly available for passes without barcodes, or passes with Code 128, PDF417, or QR Code barcodes"

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(passObject: Binding<PassObject>) {
        _passObject = passObject
        _tempBackground = State(initialValue: UIImage(data: passObject.wrappedValue.backgroundImage))
    }

    var body: some View {
        NavigationView {
            content
        }
        .sheetOrFullScreenCover(item: $imageForCrop) { item in
            SwiftyCropView(
                imageToCrop: item.image,
                maskShape: .rectangle,
                configuration: SwiftyCropConfiguration(
                    rectAspectRatio: PassKitConstants.passAspectRatio,
                    fonts: SwiftyCropConfiguration.Fonts(
                        interactionInstructions: Font.system(size: 16, weight: .bold, design: .rounded)
                    ),
                    colors: .appColors(colorScheme: colorScheme)
                )
            ) { croppedImage in
                tempBackground = croppedImage
            }
        }
    }

    // On iPhone, verticalSizeClass reflects interface orientation and is unaffected by
    // keyboard height changes (unlike measuring geometry size directly).
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }

    @ViewBuilder
    private var content: some View {
        Group {
            if isLandscape {
                landscapeLayout
            } else {
                portraitLayout
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Background Image")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save", systemImage: "checkmark") {
                    if let background = tempBackground {
                        // Store the largest (3x) variant so imports/exports can downscale as needed
                        passObject.backgroundImage = background.pngData() ?? Data()

                        passObject.stripImage = Data()

                        // Center-crop existing thumbnail to 1:1 to match background image pass layout
                        if passObject.thumbnailImage != Data(), let thumbUI = UIImage(data: passObject.thumbnailImage), let cgThumb = thumbUI.cgImage {
                            let pixelW = CGFloat(cgThumb.width)
                            let pixelH = CGFloat(cgThumb.height)
                            let side = min(pixelW, pixelH)
                            let cropRect = CGRect(
                                x: (pixelW - side) / 2,
                                y: (pixelH - side) / 2,
                                width: side,
                                height: side
                            )
                            if let cropped = cgThumb.cropping(to: cropRect) {
                                passObject.thumbnailImage = UIImage(cgImage: cropped, scale: thumbUI.scale, orientation: thumbUI.imageOrientation).pngData() ?? passObject.thumbnailImage
                            }
                        }
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
        .navigationBarTitleDisplayMode(.inline)
        .background(colorScheme == .light ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
        .onChange(of: passObject.backgroundImage) {
            if passObject.backgroundImage != Data() {
                // Force white text when a background color is set
                passObject.foregroundColor = Color.white.toHex()
            }
        }
    }

    @ViewBuilder
    private var portraitLayout: some View {
        ScrollView {
            VStack(spacing: 20) {
                backgroundPreviewView
                formFields
            }
            .padding()
        }
    }

    @ViewBuilder
    private var landscapeLayout: some View {
        HStack(spacing: 0) {
            backgroundPreviewView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(60) // because this image/preview is taller, it needs more padding to shrink it so it doesn't clip with the toolbar
                .ignoresSafeArea(edges: [.top, .bottom]) // extend past notch/dynamic island (top) and home indicator (bottom) to center against full device height; also stops the keyboard from resizing/shifting this pane

            Divider()

            ScrollView {
                formFields
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private var backgroundPreviewView: some View {
        HStack(alignment: .center) {
            Spacer()
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
                        .aspectRatio(PassKitConstants.passAspectRatio, contentMode: .fit)
                        .frame(maxHeight: 300)
                        .foregroundColor(Color.gray)
                        .opacity(0.5)
                    VStack(spacing: 10) {
                        Text("Add a\nBackground Image")
                            .multilineTextAlignment(.center)
                        Button {
                            showAlert.toggle()
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .foregroundColor(Color.gray)
                    .opacity(0.7)
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity, alignment: .center)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text(alertTitleText),
                          message: Text(alertDescriptionText),
                          dismissButton: .default(Text("OK")))
                }
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var formFields: some View {
        VStack(spacing: 20) {
            Menu {
                Button("Choose Photo", systemImage: "photo") {
                    isPhotoPickerPresented = true
                }

                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Take Photo", systemImage: "camera") {
                        isCameraPresented = true
                    }
                }
            } label: {
                Text(tempBackground == nil ? "Select a Background Image" : "Change Background Image")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 6)
            }
            .compositingGroup() //  fixes _UIReparentingView warning. See https://stackoverflow.com/questions/79871713/ios-26-broken-view-hierarchy-on-menu/79958545#79958545
            .photosPicker(isPresented: $isPhotoPickerPresented, selection: $photoItem, matching: .any(of: [.images, .not(.videos)]))
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
            .glassProminentButtonStyleIfAvailable()
            .fullScreenCover(isPresented: $isCameraPresented) {
                CameraImagePicker { image in
                    imageForCrop = IdentifiableImage(image: image)
                }
                .ignoresSafeArea()
            }

            if tempBackground != nil {
                Button(role: .destructive) {
                    passObject.backgroundImage = Data()
                    presentationMode.wrappedValue.dismiss()
                }
                label: {
                    Text("Remove Background Image")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.vertical, 12)
                .listSectionBackgroundModifier()
            }

            Spacer()
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
