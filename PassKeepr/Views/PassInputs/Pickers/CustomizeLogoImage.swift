import _PhotosUI_SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import MCEmojiPicker
import SwiftUI
import SymbolPicker
import Vision

struct CustomizeLogoImage: View {
    var placeholderColor: Color
    @State private var tempLogoImageType: LogoImageType
    @Binding var passObject: PassObject
    @State private var isTransparencyOn: Bool = false
    @State private var isPhotosPickerOn: Bool = false
    @State private var isEmojiPickerOn: Bool = false
    @State private var emoji: String = ""

    @State private var icon: String = ""
    @State private var isSymbolPickerOn = false

    @State private var tempLogo: UIImage?
    @State private var tempLogoNoBackground: UIImage?
    @State private var isTransparencyAvailable: Bool = true

    @State private var symbolSize: CGSize = .init(width: 1, height: 1)

    @State private var photoItem: PhotosPickerItem?

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(passObject: Binding<PassObject>, placeholderColor: Color) {
        _tempLogoImageType = State(initialValue: passObject.wrappedValue.logoImageType)
        self.placeholderColor = placeholderColor
        _passObject = passObject
        _tempLogo = State(initialValue: UIImage(data: passObject.wrappedValue.logoImage))
        _isTransparencyAvailable = State(initialValue: tempLogoNoBackground != nil)
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Button(action: {
                        withAnimation {
                            tempLogoImageType = LogoImageType.none
                            tempLogo = nil
                        }
                    }) {
                        Text("None")
                            .foregroundColor(tempLogoImageType == LogoImageType.none ? Color(.systemBackground) : Color(.label))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(tempLogoImageType == LogoImageType.none ? Color.blue : Color(.secondarySystemFill))
                    .foregroundColor(Color(.label))
                    .cornerRadius(8)
                    .animation(.spring, value: tempLogoImageType)
                    .buttonStyle(.plain)
                    .padding(0)

                    Spacer(minLength: 20)

                    Button(action: {
                        withAnimation {
                            isPhotosPickerOn = true
                        }
                    }) {
                        Text("Photo")
                            .foregroundColor(tempLogoImageType == LogoImageType.photo ? Color(.systemBackground) : Color(.label))
                    }
                    .photosPicker(isPresented: $isPhotosPickerOn, selection: $photoItem, matching: .any(of: [.images, .not(.videos)]))
                    .onChange(of: photoItem) {
                        Task {
                            tempLogoImageType = LogoImageType.photo
                            if let loaded = try? await photoItem?.loadTransferable(type: Data.self) {
                                tempLogo = UIImage(data: loaded)
                            } else {
                                print("Failed")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background((tempLogoImageType == LogoImageType.photo) ? Color.blue : Color(.secondarySystemFill))
                    .foregroundColor(Color(.label))
                    .cornerRadius(8)
                    .animation(.spring, value: tempLogoImageType)
                    .buttonStyle(.plain)
                    .padding(0)
//                    .onTapGesture {withAnimation {selectedButton = 0}}

                    Spacer(minLength: 20)

                    Button(action: {
                        withAnimation {
                            isEmojiPickerOn = true
                        }
                    }) {
                        Text("Emoji")
                            .foregroundColor(tempLogoImageType == LogoImageType.emoji ? Color(.systemBackground) : Color(.label))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background((tempLogoImageType == LogoImageType.emoji) ? Color.blue : Color(.secondarySystemFill))
                    .foregroundColor(Color(.label))
                    .cornerRadius(8)
                    .animation(.spring, value: tempLogoImageType)
                    .buttonStyle(.plain)
                    .padding(0)
                    .emojiPicker(
                        isPresented: $isEmojiPickerOn,
                        selectedEmoji: $emoji
                    )
                    .onChange(of: emoji) {
                        print(emoji)
                        tempLogoImageType = LogoImageType.emoji
                        tempLogo = ImageRenderer(content:
                            Text(emoji)
                                .padding(-30)
                                .scaledToFill()
                                .font(.system(size: 1000))
                                .minimumScaleFactor(0.1)
                                .frame(width: 500, height: 500)
                        ).uiImage
                    }

                    Spacer(minLength: 20)

                    Button(action: {
                        withAnimation {
                            isSymbolPickerOn = true
                        }
                    }) {
                        Text("Symbol")
                            .foregroundColor(tempLogoImageType == LogoImageType.symbol ? Color(.systemBackground) : Color(.label))
                    }
                    .onChange(of: icon) {
                        tempLogoImageType = LogoImageType.symbol
                        print(icon)
                        tempLogo = ImageRenderer(content:
                            Image(systemName: icon)
                                .resizable()
                                .font(.system(size: 1000))
                                .scaledToFit()
                                .frame(maxWidth: 1000, maxHeight: 1000) // Adjust size as needed
                                .foregroundStyle(Color(hex: passObject.foregroundColor))).uiImage
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background((tempLogoImageType == LogoImageType.symbol) ? Color.blue : Color(.secondarySystemFill))
                    .foregroundColor(Color(.label))
                    .cornerRadius(8)
                    .animation(.spring, value: tempLogoImageType)
                    .buttonStyle(.plain)
                    .padding(0)
                    .sheet(isPresented: $isSymbolPickerOn) {
                        SymbolPicker(symbol: $icon)
                    }
                }
            } header: {
                if let logo = tempLogo, !isTransparencyOn {
                    HStack {
                        Spacer()
                        Image(uiImage: logo)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 80)
                            .padding(20)
                        Spacer()
                    }
                } else if let logoNoBg = tempLogoNoBackground, isTransparencyOn {
                    HStack {
                        Spacer()
                        Image(uiImage: logoNoBg)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 80)
                            .padding(20)
                        Spacer()
                    }
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                            .frame(maxHeight: 80)
                            .aspectRatio(3.2, contentMode: .fit)
                        Text("Logo Image")
                            .scaledToFit()
                            .textCase(nil)
                    }
                    .padding([.top, .bottom], 20)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }

            if tempLogoImageType == LogoImageType.photo {
                Toggle(isOn: $isTransparencyOn) {
                    Text("Transparent background")
                        .opacity(isTransparencyAvailable ? 1 : 0.2)
                }
                .disabled(!isTransparencyAvailable)
            }

            Section {
                Button(
                    action: {
                        if tempLogoImageType == LogoImageType.none {
                            passObject.logoImage = Data()
                        } else {
                            if isTransparencyOn {
                                if let logoNoBg = tempLogoNoBackground {
                                    passObject.logoImage = logoNoBg.pngData()!
                                }
                            } else {
                                if let logo = tempLogo {
                                    passObject.logoImage = logo.pngData()!
                                }
                            }
                        }
                        passObject.logoImageType = tempLogoImageType
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
        .onChange(of: tempLogo) {
            Task {
                if let tempNoBg = removeBackground(image: tempLogo) {
                    tempLogoNoBackground = tempNoBg
                    isTransparencyAvailable = true
                }
                isTransparencyOn = false
            }
        }
    }
}

private func createMask(from inputImage: CIImage) -> CIImage? {
    let request = VNGenerateForegroundInstanceMaskRequest()
    let handler = VNImageRequestHandler(ciImage: inputImage)

    do {
        try handler.perform([request])

        if let result = request.results?.first {
            let mask = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
            let ciImage = CIImage(cvPixelBuffer: mask)

            // Apply Gaussian blur to the mask
            guard let blurFilter = CIFilter(name: "CIGaussianBlur") else {
                return ciImage
            }

            blurFilter.setValue(ciImage, forKey: kCIInputImageKey)
            blurFilter.setValue(0.5, forKey: kCIInputRadiusKey)

            return blurFilter.outputImage ?? ciImage
        }
    } catch {
        print(error)
    }

    return nil
}

private func applyMask(mask: CIImage, to image: CIImage) -> CIImage {
    let filter = CIFilter.blendWithMask()

    filter.inputImage = image
    filter.maskImage = mask
    filter.backgroundImage = CIImage.empty()

    return filter.outputImage!
}

private func convertToUIImage(ciImage: CIImage, originalOrientation: UIImage.Orientation) -> UIImage {
    guard let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent) else {
        fatalError("Failed to render CGImage")
    }

    return UIImage(cgImage: cgImage, scale: 1.0, orientation: originalOrientation)
}

private func removeBackground(image: UIImage?) -> UIImage? {
    // Store the original orientation
    if image == nil {
        return nil
    }

    let originalOrientation = image!.imageOrientation

    // Create CIImage while preserving orientation properties
    guard var inputImage = CIImage(image: image!) else {
        print("Failed to create CIImage")
        return nil
    }

    // Apply orientation transform if needed
    if let orientationProperty = inputImage.properties[kCGImagePropertyOrientation as String] as? UInt32 {
        inputImage = inputImage.oriented(CGImagePropertyOrientation(rawValue: orientationProperty)!)
    }

    guard let maskImage = createMask(from: inputImage) else {
        print("Failed to create mask")
        return nil
    }

    let outputImage = applyMask(mask: maskImage, to: inputImage)
    let processedImage = convertToUIImage(ciImage: outputImage, originalOrientation: originalOrientation)
    return cropToVisibleContent(image: processedImage)
}

private func cropToVisibleContent(image: UIImage) -> UIImage? {
    // Convert UIImage to CGImage
    guard let cgImage = image.cgImage else { return nil }

    // Get image dimensions
    let width = cgImage.width
    let height = cgImage.height

    // Create bitmap context
    guard let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: width * 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }

    // Draw image in context
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

    // Get image data
    guard let pixelData = context.data else { return nil }

    // Find bounds of non-transparent pixels
    var minX = width
    var minY = height
    var maxX = 0
    var maxY = 0

    let data = pixelData.bindMemory(to: UInt8.self, capacity: width * height * 4)

    for y in 0 ..< height {
        for x in 0 ..< width {
            let pixelIndex = (width * y + x) * 4
            let alpha = data[pixelIndex + 3]

            if alpha > 0 {
                minX = min(minX, x)
                minY = min(minY, y)
                maxX = max(maxX, x)
                maxY = max(maxY, y)
            }
        }
    }

    // Add padding
    let padding = 1
    minX = max(0, minX - padding)
    minY = max(0, minY - padding)
    maxX = min(width - 1, maxX + padding)
    maxY = min(height - 1, maxY + padding)

    // Create cropping rectangle
    let rect = CGRect(
        x: minX,
        y: minY,
        width: maxX - minX + 1,
        height: maxY - minY + 1
    )

    // Crop the image
    guard let croppedCGImage = cgImage.cropping(to: rect) else { return nil }
    return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
}

#Preview {
    CustomizeLogoImage(passObject: .constant(MockModelData().passObjects[0]), placeholderColor: Color.black)
}
