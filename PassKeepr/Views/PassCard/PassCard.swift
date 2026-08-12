import SwiftUI

struct PassCard: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var passSigner: pkPassSigner
    @Environment(\.colorScheme) var colorScheme
    @State private var size: CGSize = CGSizeZero
    @State private var passBackgroundBrightness: BackgroundBrightness = .normal
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var cachedBackgroundImage: UIImage?
    var passObject: PassObject

    var body: some View {
        passCardBackground
            .background(GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        size = geometry.size
                    }
                    .onChange(of: geometry.size) {
                        Task {
                            size = geometry.size
                        }
                    }
            })
            .onChange(of: passObject.backgroundImage) { _, newValue in
                decodeBackgroundImageIfNeeded(newValue)
                determineBackgroundColor()
            }
            .onChange(of: passObject.backgroundColor) {
                determineBackgroundColor()
            }
            .onAppear {
                decodeBackgroundImageIfNeeded(passObject.backgroundImage)
                determineBackgroundColor()
            }
            .overlay(
                VStack {
                    PassCardTopSection(passObject: passObject)
                        .frame(height: size.height * 0.2)
                        .padding(0)

                    if getIsStripImageSupported(passObject: passObject) && passObject.stripImage != Data() && passObject.isCustomStripImageOn {
                        if let uiImage = UIImage(data: passObject.stripImage) {
                            let imageAspectRatio = uiImage.size.width / uiImage.size.height
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .aspectRatio(imageAspectRatio, contentMode: .fit)
                                .overlay(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.black.opacity(0.1))
                                        .frame(width: 2)
                                }
                                .overlay(alignment: .trailing) {
                                    Rectangle()
                                        .fill(Color.black.opacity(0.1))
                                        .frame(width: 2)
                                }
                                .padding(.top, -10)
                        }
                    } else if (passObject.primaryFieldText != "" || passObject.primaryFieldLabel != "") && !passObject.isCustomStripImageOn {
                        HStack {
                            ZStack(alignment: .leading) {
                                Text(passObject.primaryFieldLabel)
                                    .lineLimit(1)
                                    .frame(maxHeight: .infinity, alignment: .topLeading)
                                    .foregroundColor(Color(hex: passObject.labelColor))
                                    .textCase(.uppercase)
                                    .font(.system(size: 11))
                                    .fontWeight(.semibold)
                                    .padding(0)
                                    .padding(.top, -2)

                                Text((passObject.isCurrencyFieldsOn && passObject.isPrimaryFieldCurrency) ? formattedCurrencyText(passObject.primaryFieldText, currencyCode: passObject.currencyCode) : passObject.primaryFieldText)
                                    .lineLimit(1)
                                    .frame(maxHeight: .infinity, alignment: .topLeading)
                                    .foregroundColor(Color(hex: passObject.foregroundColor))
                                    .font(.system(size: 14))
                                    .fontWeight(.thin)
                                    .padding(0)
                                    .padding(.top, 9)
                                    .minimumScaleFactor(0.34)
                            }
                            .padding(.leading, 8)
                            Spacer()
                        }
                        .frame(height: size.height * 0.1)
                    }

                    if passObject.secondaryFieldOneLabel != "" || passObject.secondaryFieldOneText != "" {
                        HStack {
                            ZStack(alignment: .leading) {
                                Text(passObject.secondaryFieldOneLabel)
                                    .lineLimit(1)
                                    .frame(maxHeight: .infinity, alignment: .topLeading)
                                    .foregroundColor(Color(hex: passObject.labelColor))
                                    .textCase(.uppercase)
                                    .font(.system(size: 9))
                                    .fontWeight(.semibold)
                                    .padding(0)
                                    .padding(.top, -2)

                                Text((passObject.isCurrencyFieldsOn && passObject.isSecondaryFieldOneCurrency) ? formattedCurrencyText(passObject.secondaryFieldOneText, currencyCode: passObject.currencyCode) : passObject.secondaryFieldOneText)
                                    .lineLimit(1)
                                    .frame(maxHeight: .infinity, alignment: .topLeading)
                                    .foregroundColor(Color(hex: passObject.foregroundColor))
                                    .font(.system(size: 12))
                                    .fontWeight(.thin)
                                    .padding(0)
                                    .padding(.top, 7)
                                    .minimumScaleFactor(0.34)
                            }
                            .padding(.leading, 8)
                            Spacer()
                        }
                        .frame(height: size.height * 0.1)
                    }
                    Spacer()

                    if passObject.barcodeType == BarcodeType.qr, passObject.barcodeString != "" {
                        QRCodeView(data: passObject.barcodeString, correctionLevel: passObject.qrCodeCorrectionLevel, encoding: passObject.qrCodeEncoding)
                            .padding(3)
                            .background {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white)
                            }
                            .frame(height: 60)
                            .padding(.bottom, 15)
                    } else if passObject.barcodeType == BarcodeType.code128 || passObject.barcodeType == BarcodeType.pdf417 {
                        Group {
                            if passObject.barcodeType.isEnteredBarcodeValueValid(string: passObject.barcodeString) == true {
                                if passObject.barcodeType == BarcodeType.code128 {
                                    Code128View(data: passObject.barcodeString)
                                        .padding(10)
                                } else if passObject.barcodeType == BarcodeType.pdf417 {
                                    PDF417View(data: passObject.barcodeString)
                                        .padding(5)
                                }
                            }
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.white)
                        }
                        .aspectRatio(3, contentMode: .fit)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 15)
                    }
                }
            )
            .contextMenu {
                let fileManager = FileManager.default
                let appSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                let destinationURL = appSupportDirectory.appendingPathComponent("\(passObject.id).pkpass")
                ShareLink(item: destinationURL) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }

                Button(action: {
                    let newPass = passObject.duplicate()
                    modelData.passObjects.append(newPass)
                    modelData.encodePassObjects()

                    if generatePass(passObject: newPass) == nil {
                        alertMessage = "Failed to generate pass file"
                        showAlert = true
                    }
                }) {
                    Label("Duplicate", systemImage: "rectangle.portrait.on.rectangle.portrait")
                }

                Button(role: .destructive, action: {
                    modelData.deleteItemByID(passObject.id)
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
    }

    private var passCardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(shadowColor)
                .background(
                    cachedBackgroundImage != nil ?
                        Image(uiImage: cachedBackgroundImage!)
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .blur(radius: 6)
                        : nil // No background if image is nil
                )
                .scaleEffect(0.95, anchor: .bottom)
                .blur(radius: 3)
                .opacity(shadowOpacity)
                .padding(.bottom, -4)
                .allowsHitTesting(false)

            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(passBackgroundBrightness == .veryDark ? Color.white.opacity(0.15) : Color.black.opacity(0.1), lineWidth: 2) // strokeBorder draws the line only on the inside of the view
                .background(
                    cachedBackgroundImage != nil ?
                        AnyView(
                            Image(uiImage: cachedBackgroundImage!)
                                .resizable()
                                .scaleEffect(1.05) // Scale up the image slightly to prevent a semitransparent halo around the image
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .blur(radius: 6)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        )
                        : AnyView(RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(hex: passObject.backgroundColor)))
                )
        }
    }

    private func decodeBackgroundImageIfNeeded(_ data: Data) {
        guard data != Data() else {
            cachedBackgroundImage = nil
            return
        }
        cachedBackgroundImage = UIImage(data: data)
    }

    private var shadowColor: Color {
        if passObject.backgroundImage != Data() {
            return Color.clear
        }

        switch passBackgroundBrightness {
        case .veryDark:
            return colorScheme == .light ? Color(hex: passObject.backgroundColor) : Color.gray.opacity(0.6)
        case .normal:
            return Color(hex: passObject.backgroundColor)
        case .veryLight:
            return colorScheme == .light ? Color.gray : Color(hex: passObject.backgroundColor)
        }
    }

    private var shadowOpacity: Double {
        switch passBackgroundBrightness {
        case .veryDark:
            return colorScheme == .light ? 0.5 : 0.4
        case .normal:
            return colorScheme == .light ? 0.5 : 0.6
        case .veryLight:
            return 0.4
        }
    }

    func determineBackgroundColor() {
        if let cached = PassCardBrightnessCache.shared.brightness(for: passObject) {
            passBackgroundBrightness = cached
            return
        }

        // No background image: brightness can be computed directly from the hex color,
        // no offscreen rendering needed at all.
        guard passObject.backgroundImage != Data() else {
            let color = passObject.backgroundColor
            let red = CGFloat((color >> 16) & 0xFF) / 255.0
            let green = CGFloat((color >> 8) & 0xFF) / 255.0
            let blue = CGFloat(color & 0xFF) / 255.0
            let result = Self.classify((0.299 * red) + (0.587 * green) + (0.114 * blue))
            passBackgroundBrightness = result
            PassCardBrightnessCache.shared.setBrightness(result, for: passObject)
            return
        }

        // Background image case: sample brightness from a small downsized copy of the already-decoded
        // image (instead of re-rendering the whole styled card via ImageRenderer), off the main thread.
        guard let image = cachedBackgroundImage else { return }
        let object = passObject
        Task.detached(priority: .utility) {
            let brightness = image.resizeToFit(maxWidth: 40, maxHeight: 40).averageBrightness() ?? 0.5
            let result = Self.classify(brightness)
            PassCardBrightnessCache.shared.setBrightness(result, for: object)
            await MainActor.run {
                self.passBackgroundBrightness = result
            }
        }
    }

    private static func classify(_ brightness: CGFloat) -> BackgroundBrightness {
        if brightness < 0.2 {
            return .veryDark
        } else if brightness > 0.2, brightness < 0.55 {
            return .normal
        } else {
            return .veryLight
        }
    }
}

/// Caches computed background brightness per pass so that LazyVGrid recycling cells
/// during scrolling doesn't repeatedly re-trigger expensive brightness computation.
private final class PassCardBrightnessCache {
    static let shared = PassCardBrightnessCache()

    private struct Key: Hashable {
        let id: UUID
        let imageByteCount: Int
        let backgroundColor: UInt
    }

    private var cache: [Key: BackgroundBrightness] = [:]
    private let lock = NSLock()

    private func key(for passObject: PassObject) -> Key {
        Key(id: passObject.id, imageByteCount: passObject.backgroundImage.count, backgroundColor: passObject.backgroundColor)
    }

    func brightness(for passObject: PassObject) -> BackgroundBrightness? {
        lock.lock(); defer { lock.unlock() }
        return cache[key(for: passObject)]
    }

    func setBrightness(_ brightness: BackgroundBrightness, for passObject: PassObject) {
        lock.lock(); defer { lock.unlock() }
        cache[key(for: passObject)] = brightness
    }
}

#Preview {
    PassCard(passObject: MockModelData().passObjects[0])
}
