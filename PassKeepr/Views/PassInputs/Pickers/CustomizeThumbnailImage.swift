import _PhotosUI_SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import MCEmojiPicker
import SwiftUI
import SymbolPicker
import Vision

struct CustomizeThumbnailImage: View {
    @Environment(\.colorScheme) var colorScheme

    @State private var tempThumbnailImageType: ImageType
    @Binding var passObject: PassObject
    @State private var isTransparencyOn: Bool = false
    @State private var isPhotosPickerOn: Bool = false
    @State private var isEmojiPickerOn: Bool = false
    @State private var emoji: String = ""

    @State private var symbolName: String = ""
    @State private var symbolColor: Color = .black
    @State private var isSymbolPickerOn = false

    @State private var tempThumbnail: UIImage?
    @State private var tempThumbnailNoBackground: UIImage?
    @State private var isTransparencyAvailable: Bool = true

    @State private var photoItem: PhotosPickerItem?

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(passObject: Binding<PassObject>) {
        _tempThumbnailImageType = State(initialValue: passObject.wrappedValue.thumbnailImageType)
        _passObject = passObject
        _tempThumbnail = State(initialValue: UIImage(data: passObject.wrappedValue.thumbnailImage))
        _isTransparencyAvailable = State(initialValue: false)
        _symbolName = State(initialValue: passObject.wrappedValue.thumbnailSymbolName)
        if passObject.wrappedValue.thumbnailSymbolName != "" {
            _symbolColor = State(initialValue: Color(hex: passObject.wrappedValue.thumbnailSymbolColor))
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let thumbnail = tempThumbnail, !isTransparencyOn {
                    HStack {
                        Spacer()
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 80)
                            .padding(20)
                        Spacer()
                    }
                } else if let thumbnailNoBg = tempThumbnailNoBackground, isTransparencyOn {
                    HStack {
                        Spacer()
                        Image(uiImage: thumbnailNoBg)
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
                            .frame(maxHeight: 120)
                            .aspectRatio(1, contentMode: .fit)
                            .foregroundColor(Color.gray)
                            .opacity(0.5)
                        Text("Thumbnail\nImage")
                            .scaledToFit()
                            .foregroundColor(Color.gray)
                            .opacity(0.7)
                            .multilineTextAlignment(.center)
                    }
                    .padding([.top, .bottom], 20)
                    .frame(maxWidth: .infinity, alignment: .center)
                }

                Picker("Thumbnail type", selection: $tempThumbnailImageType) {
                    ForEach(ImageType.allCases, id: \.self) { type in
                        Text(String(describing: type))
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: tempThumbnailImageType) {
                    tempThumbnail = nil
                }
                .padding(14)
                .listSectionBackgroundModifier()
                .onChange(of: emoji) {
                    print(emoji)
                    tempThumbnailImageType = ImageType.emoji
                    tempThumbnail = ImageRenderer(content:
                        Text(emoji)
                            .padding(-30)
                            .scaledToFill()
                            .font(.system(size: 1000))
                            .minimumScaleFactor(0.1)
                            .frame(width: 500, height: 500)
                    ).uiImage
                }
                .sheet(isPresented: $isSymbolPickerOn) {
                    SymbolPicker(symbol: $symbolName)
                }

                switch tempThumbnailImageType {
                case .photo:
                    PhotosPicker(selection: $photoItem, matching: .any(of: [.images, .not(.videos)])) {
                        Text(tempThumbnail == nil ? "Select a Thumbnail Image" : "Change Thumbnail Image")
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .onChange(of: photoItem) {
                        Task {
                            if let loaded = try? await photoItem?.loadTransferable(type: Data.self) {
                                var image = UIImage(data: loaded)!
                                // Apply aspect ratio constraint even without background removal
                                image = applyAspectRatioConstraint(to: image) ?? image
                                tempThumbnail = image
                            } else {
                                print("Failed")
                            }
                        }
                    }
                    .padding([.top, .bottom], 12)
                    .accentColorProminentButtonStyleIfAvailable()

                    Toggle(isOn: $isTransparencyOn) {
                        Text("Transparent background")
                            .opacity(isTransparencyAvailable ? 1 : 0.2)
                    }
                    .disabled(!isTransparencyAvailable)
                    .padding(14)
                    .listSectionBackgroundModifier()
                case .emoji:
                    Button {
                        isEmojiPickerOn = true
                    } label: {
                        Text(tempThumbnail == nil ? "Select an Emoji" : "Change Emoji")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .foregroundColor(.white)
                    .accentColorProminentButtonStyleIfAvailable()
                    .emojiPicker(
                        isPresented: $isEmojiPickerOn,
                        selectedEmoji: $emoji
                    )
                case .symbol:
                    Button {
                        isSymbolPickerOn = true
                    } label: {
                        Text(tempThumbnail == nil ? "Select a Symbol" : "Change Symbol")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .foregroundColor(Color.white)
                    .accentColorProminentButtonStyleIfAvailable()

                    ColorPicker("Symbol Color", selection: $symbolColor, supportsOpacity: false)
                        .padding(16)
                        .listSectionBackgroundModifier()
                case .none:
                    EmptyView()
                }

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Thumbnail Image")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        updateThumbnailImage()
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
            .photosPicker(isPresented: $isPhotosPickerOn, selection: $photoItem, matching: .any(of: [.images, .not(.videos)]))
            .onChange(of: photoItem) {
                Task {
                    tempThumbnailImageType = ImageType.photo
                    if let loaded = try? await photoItem?.loadTransferable(type: Data.self) {
                        var image = UIImage(data: loaded)!
                        // Apply aspect ratio constraint
                        image = applyAspectRatioConstraint(to: image) ?? image
                        tempThumbnail = image
                    } else {
                        print("Failed")
                    }
                }
            }
            .padding()
            .background(colorScheme == .light ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
            .onChange(of: tempThumbnail) {
                Task {
                    // Check if Vision framework is available for background removal
                    if #available(iOS 17, *) {
                        if let tempNoBg = removeBackground(image: tempThumbnail) {
                            tempThumbnailNoBackground = tempNoBg
                            isTransparencyAvailable = true
                        }
                    } else {
                        print("DEBUG: Background removal not available on this device/OS")
                        isTransparencyAvailable = false
                    }
                    isTransparencyOn = false
                }
            }
            .onChange(of: symbolName) {
                renderSymbol()
            }
            .onChange(of: symbolColor) {
                renderSymbol()
            }
            .onAppear {
                if symbolName == "" {
                    symbolColor = colorScheme == .light ? .black : .white
                }
            }
        }
    }

    private func updateThumbnailImage() {
        if tempThumbnailImageType == ImageType.none {
            passObject.thumbnailImage = Data()
        } else if tempThumbnailImageType == ImageType.photo {
            if isTransparencyOn {
                if let thumbnailNoBg = tempThumbnailNoBackground {
                    passObject.thumbnailImage = thumbnailNoBg.pngData()!
                }
            } else {
                if let thumbnail = tempThumbnail {
                    passObject.thumbnailImage = thumbnail.pngData()!
                }
            }
        } else if tempThumbnailImageType == ImageType.symbol {
            passObject.thumbnailSymbolColor = symbolColor.toHex()
            if let thumbnail = tempThumbnail {
                passObject.thumbnailImage = thumbnail.pngData()!
            }
        } else if tempThumbnailImageType == ImageType.emoji {
            if let thumbnail = tempThumbnail {
                passObject.thumbnailImage = thumbnail.pngData()!
            }
        }
        passObject.thumbnailImageType = tempThumbnailImageType
        passObject.thumbnailSymbolName = symbolName
        passObject.thumbnailSymbolColor = symbolColor.toHex()
        presentationMode.wrappedValue.dismiss()
    }

    private func renderSymbol() {
        if symbolName != "" {
            tempThumbnail = ImageRenderer(content:
                Image(systemName: symbolName)
                    .resizable()
                    .font(.system(size: 1000))
                    .scaledToFit()
                    .frame(maxWidth: 1000, maxHeight: 1000)
                    .foregroundStyle(symbolColor)).uiImage
        }
    }
}

private func applyAspectRatioConstraint(to image: UIImage, within rect: CGRect? = nil) -> UIImage? {
    guard let cgImage = image.cgImage else { return nil }

    let width = CGFloat(cgImage.width)
    let height = CGFloat(cgImage.height)

    let constraintRect = rect ?? CGRect(x: 0, y: 0, width: width, height: height)
    let aspectRatio = constraintRect.width / constraintRect.height
    let minRatio = 2.0 / 3.0 // 2:3 (tall)
    let maxRatio = 3.0 / 2.0 // 3:2 (wide)

    var finalRect = constraintRect

    if aspectRatio > maxRatio {
        // Too wide, crop width to 3:2
        let newWidth = finalRect.height * maxRatio
        finalRect.origin.x += (finalRect.width - newWidth) / 2
        finalRect.size.width = newWidth
    } else if aspectRatio < minRatio {
        // Too tall, crop height to 2:3
        let newHeight = finalRect.width / minRatio
        finalRect.origin.y += (finalRect.height - newHeight) / 2
        finalRect.size.height = newHeight
    }

    guard let croppedCGImage = cgImage.cropping(to: finalRect) else { return nil }
    return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
}

private func createMask(from inputImage: CIImage) -> CIImage? {
    let request = VNGenerateForegroundInstanceMaskRequest()
    let handler = VNImageRequestHandler(ciImage: inputImage)

    do {
        try handler.perform([request])

        if let result = request.results?.first {
            let mask = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
            let ciImage = CIImage(cvPixelBuffer: mask)

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
    if image == nil {
        return nil
    }

    let originalOrientation = image!.imageOrientation

    guard var inputImage = CIImage(image: image!) else {
        print("Failed to create CIImage")
        return nil
    }

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
    guard let cgImage = image.cgImage else { return nil }

    let width = cgImage.width
    let height = cgImage.height

    guard let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: width * 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

    guard let pixelData = context.data else { return nil }

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

    let padding = 1
    minX = max(0, minX - padding)
    minY = max(0, minY - padding)
    maxX = min(width - 1, maxX + padding)
    maxY = min(height - 1, maxY + padding)

    let visibleRect = CGRect(
        x: minX,
        y: minY,
        width: maxX - minX + 1,
        height: maxY - minY + 1
    )

    return applyAspectRatioConstraint(to: image, within: visibleRect)
}

#Preview {
    CustomizeThumbnailImage(passObject: .constant(MockModelData().passObjects[0]))
}
