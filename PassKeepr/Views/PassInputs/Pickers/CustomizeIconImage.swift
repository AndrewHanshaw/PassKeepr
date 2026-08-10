import _PhotosUI_SwiftUI
import SwiftUI
import SwiftyCrop

struct CustomizeIconImage: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @Binding var passObject: PassObject

    @State private var tempIcon: UIImage?
    @State private var isPhotoPickerPresented = false
    @State private var isCameraPresented = false

    @State private var photoItem: PhotosPickerItem?
    @State private var imageForCrop: IdentifiableImage?

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(passObject: Binding<PassObject>) {
        _passObject = passObject
        _tempIcon = State(initialValue: UIImage(data: passObject.wrappedValue.passIcon))
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
                    rectAspectRatio: 1.0,
                    allowAspectRatioResizing: false, // Pass icons must always be square
                    fonts: SwiftyCropConfiguration.Fonts(
                        interactionInstructions: Font.system(size: 16, weight: .bold, design: .rounded)
                    ),
                    colors: .appColors(colorScheme: colorScheme)
                )
            ) { croppedImage in
                tempIcon = croppedImage
            }
            .interactiveDismissDisabled()
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
                Text("Pass Icon")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save", systemImage: "checkmark") {
                    updateIconImage()
                }
                .toolbarConfirmButtonModifier()
                .disabled(tempIcon == nil)
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
                iconPreviewView
                    .frame(maxHeight: 80)
                    .padding(20)
                formFields
            }
            .padding()
        }
    }

    @ViewBuilder
    private var landscapeLayout: some View {
        HStack(spacing: 0) {
            iconPreviewView
                .frame(maxHeight: 160)
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
    private var iconPreviewView: some View {
        if let icon = tempIcon {
            HStack {
                Spacer()
                Image(uiImage: icon)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                Spacer()
            }
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                    .foregroundColor(Color.gray)
                    .opacity(0.5)
                Text("Pass Icon")
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.34)
                    .foregroundColor(Color.gray)
                    .opacity(0.7)
                    .padding(2)
            }
            .aspectRatio(1, contentMode: .fit)
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
                Text(tempIcon == nil ? "Select an Icon Image" : "Change Icon Image")
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

            Spacer()
        }
    }

    private func updateIconImage() {
        if let icon = tempIcon, let pngData = icon.pngData() {
            passObject.passIcon = pngData
        }
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    CustomizeIconImage(passObject: .constant(MockModelData().passObjects[0]))
}
