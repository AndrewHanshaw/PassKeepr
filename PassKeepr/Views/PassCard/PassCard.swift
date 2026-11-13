import PassKeeprCore
import SwiftUI

// Context-menu actions for the cards in PassGridView.
// A reference type because SwiftUI can't compare closure properties
// so passing closures into PassCard made every card's body re-run whenever the grid's body did (e.g. during a drag)
// The grid creates one instance and keeps it for its lifetime
// so PassCard sees the same reference every time and can skip body when nothing else changed.
final class PassCardActions {
    var share: (UUID) -> Void = { _ in }
    var duplicate: (UUID) -> Void = { _ in }
    var delete: (UUID) -> Void = { _ in }
}

struct PassCard: View {
    @Environment(\.displayScale) private var displayScale
    @State private var cachedStripImage: UIImage?
    var passObject: PassObject
    var cardSize: CGSize
    var isSigningForShare: Bool = false
    var actions = PassCardActions()

    // false for the drag preview
    // (the system can't snapshot a drawingGroup() texture, so the lifted preview comes out blank)
    // The preview draws the background live instead.
    var flattensBackground: Bool = true

    // Extra room around the card inside the flattened background texture so the shadow isn't clipped.
    private static let shadowBleed: CGFloat = 24

    // Horizontal padding on each side of the 1D barcode container.
    private static let barcodeHorizontalPadding: CGFloat = 20

    // Width available to the 1D barcode, after the horizontal padding applied to its container below.
    private var barcodeWidth: CGFloat {
        max(0, cardSize.width - 2 * Self.barcodeHorizontalPadding)
    }

    // Flattens the view for the grid
    // renders the background (shadow, background photo, scalloped path)
    // once per card into a cached texture instead of re-rasterizing it on every frame while scrolling
    // The overlay text and barcode stay vector-sharp above it.
    // Edit mode is untouched (EditablePassCard should not use this modifier)

    // drawingGroup() clips to its bounds, and the blurred shadow extends past the card
    // The card is pinned to cardSize and padded by shadowBleed before flattening
    // so the texture has room for the shadow
    // the negative padding afterwards restores the original layout size.
    @ViewBuilder
    private var cardBackground: some View {
        let background = PassCardBackgroundView(passObject: passObject, scallopsPerEdge: 30, gridCardSize: cardSize)
        if flattensBackground {
            background
                .frame(width: cardSize.width, height: cardSize.height)
                .padding(Self.shadowBleed)
                .drawingGroup()
                .padding(-Self.shadowBleed)
        } else {
            background
        }
    }

    var body: some View {
        cardBackground
            .overlay(
                VStack {
                    PassCardTopSection(passObject: passObject)
                        .frame(height: cardSize.height * 0.2)
                        .padding(0)

                    if passObject.shouldIncludeStripImage {
                        if let uiImage = cachedStripImage {
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
                        .frame(height: cardSize.height * 0.1)
                    }

                    if passObject.hasSecondaryFieldOneContent {
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
                        .frame(height: cardSize.height * 0.1)
                    }
                    Spacer()

                    if passObject.barcodeType == BarcodeType.qr, passObject.barcodeString != "" {
                        QRCodeView(data: passObject.barcodeString, correctionLevel: passObject.qrCodeCorrectionLevel, encoding: passObject.qrCodeEncoding, targetWidth: 60)
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
                                    Code128View(data: passObject.barcodeString, targetWidth: barcodeWidth)
                                        .padding(10)
                                } else if passObject.barcodeType == BarcodeType.pdf417 {
                                    PDF417View(data: passObject.barcodeString, targetWidth: barcodeWidth, targetHeight: barcodeWidth / 3)
                                        .padding(5)
                                }
                            }
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.white)
                        }
                        .aspectRatio(3, contentMode: .fit)
                        .padding(.horizontal, Self.barcodeHorizontalPadding)
                        .padding(.bottom, 15)
                    }
                }
            )
            .onAppear {
                decodeStripImage()
            }
            .onChange(of: passObject.stripImage) { _, _ in
                decodeStripImage()
            }
            .onChange(of: passObject.shouldIncludeStripImage) { _, _ in
                // shouldIncludeStripImage comes from the toggle for the custom strip image/barcode or background image
                // so it can change without stripImage itself changing.
                decodeStripImage()
            }
            .onChange(of: cardSize) { _, _ in
                // cardSize is 0 until the grid's first geometry measurement
                // a decode attempted then returns nil
                // retry once the real size (and display width) is known.
                decodeStripImage()
            }
            .contextMenu {
                Button {
                    actions.share(passObject.id)
                } label: {
                    if isSigningForShare {
                        Label("Signing...", systemImage: "hourglass")
                    } else {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
                .disabled(isSigningForShare)

                Button {
                    actions.duplicate(passObject.id)
                } label: {
                    Label("Duplicate", systemImage: "rectangle.portrait.on.rectangle.portrait")
                }

                Button(role: .destructive) {
                    actions.delete(passObject.id)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
    }

    private func decodeStripImage() {
        guard passObject.shouldIncludeStripImage else {
            cachedStripImage = nil
            return
        }

        cachedStripImage = decodedImage(from: passObject.stripImage, maxPixelSize: cardSize.width * displayScale)
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {
        // No updates needed
    }
}

#Preview {
    PassCard(passObject: MockModelData().passObjects[0], cardSize: CGSize(width: 180, height: 180 / PassKitConstants.passAspectRatio))
}
