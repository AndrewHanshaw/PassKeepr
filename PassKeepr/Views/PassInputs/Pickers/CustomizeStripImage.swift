import _PhotosUI_SwiftUI
import SwiftUI
import SwiftyCrop

struct CustomizeStripImage: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @Binding var passObject: PassObject
    @State private var tempStrip: UIImage?

    @State private var photoItem: PhotosPickerItem?
    @State private var imageForCrop: IdentifiableImage?
    @State private var isPhotoPickerPresented = false
    @State private var isCameraPresented = false

    @State private var showAlert: Bool = false

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(passObject: Binding<PassObject>) {
        _passObject = passObject
        _tempStrip = State(initialValue: UIImage(data: passObject.wrappedValue.stripImage))
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
                Text("Strip Image")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save", systemImage: "checkmark") {
                    if let strip = tempStrip {
                        passObject.stripImage = strip.pngData() ?? Data()
                        // Remove background image (incompatible with strip image)
                        passObject.updateBackgroundImage(Data())
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
    }

    @ViewBuilder
    private var portraitLayout: some View {
        ScrollView {
            VStack(spacing: 20) {
                stripPreviewView
                    .padding(.vertical, 20)
                formFields
            }
            .padding()
        }
    }

    @ViewBuilder
    private var landscapeLayout: some View {
        HStack(spacing: 0) {
            stripPreviewView
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    private var stripPreviewView: some View {
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
                Text(tempStrip == nil ? "Select a Strip Image" : "Change Strip Image")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 6)
            }
            .compositingGroup() //  fixes _UIReparentingView warning. See https://stackoverflow.com/questions/79871713/ios-26-broken-view-hierarchy-on-menu/79958545#79958545
            .glassProminentButtonStyleIfAvailable()
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
            .fullScreenCover(isPresented: $isCameraPresented) {
                CameraImagePicker { image in
                    imageForCrop = IdentifiableImage(image: image)
                }
                .ignoresSafeArea()
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
                .padding(.vertical, 12)
                .listSectionBackgroundModifier()
            }
        }
    }
}

#Preview {
    CustomizeStripImage(passObject: .constant(MockModelData().passObjects[0]))
}
