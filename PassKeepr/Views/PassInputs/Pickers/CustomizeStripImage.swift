import _PhotosUI_SwiftUI
import SwiftUI

struct CustomizeStripImage: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var passObject: PassObject
    @State private var tempStrip: UIImage?

    @State private var photoItem: PhotosPickerItem?

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
                        if let loaded = try? await photoItem?.loadTransferable(type: Data.self) {
                            var image = UIImage(data: loaded)!
                            image = cropToStripAspectRatio(image) ?? image
                            tempStrip = image
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
                        if let strip = tempStrip,
                           let cropped = cropToStripAspectRatio(strip)
                        {
                            passObject.stripImage = cropped.pngData() ?? Data()
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
    }
}

#Preview {
    CustomizeStripImage(passObject: .constant(MockModelData().passObjects[0]))
}

private func cropToStripAspectRatio(_ image: UIImage) -> UIImage? {
    guard let cgImage = image.cgImage else { return nil }

    let srcW = CGFloat(cgImage.width)
    let srcH = CGFloat(cgImage.height)
    let targetAspect = PassKitConstants.StripImage.aspectRatio

    let cropRect: CGRect
    if srcW / srcH > targetAspect {
        // Image is wider than target: crop width, center horizontally
        let cropW = srcH * targetAspect
        cropRect = CGRect(x: (srcW - cropW) / 2, y: 0, width: cropW, height: srcH)
    } else {
        // Image is taller than target: crop height, center vertically
        let cropH = srcW / targetAspect
        cropRect = CGRect(x: 0, y: (srcH - cropH) / 2, width: srcW, height: cropH)
    }

    guard let cropped = cgImage.cropping(to: cropRect) else { return nil }
    return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
}
