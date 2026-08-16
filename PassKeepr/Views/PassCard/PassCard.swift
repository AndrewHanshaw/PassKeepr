import SwiftUI

struct PassCard: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var passSigner: pkPassSigner
    @Environment(\.colorScheme) var colorScheme
    @State private var size: CGSize = CGSizeZero
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var cachedBackgroundImage: UIImage?
    var passObject: PassObject

    private var passBackgroundBrightness: BackgroundBrightness { passObject.backgroundBrightness }

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
                decodeBackgroundImage(newValue)
            }
            .onAppear {
                decodeBackgroundImage(passObject.backgroundImage)
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
            backgroundShape
                .fill(shadowColor) // Want to use fill here because there is no strokeborder for the shadow and using .background causes issues with opacity (it uses inverted colors vs the ColorScheme)
                .scaleEffect(0.95, anchor: .bottom)
                .blur(radius: 8)
                .opacity(shadowOpacity)
                .padding(.bottom, -4)

            if passObject.backgroundImage != Data() {
                imageBackground
            } else if passObject.isCoupon {
                scallopedBackground
            } else {
                plainColorBackground
            }

            gradientOverlay
        }
    }

    private var gradientOverlay: some View {
        LinearGradient(
            stops: [
                .init(color: Color.black.opacity(0.04), location: 0),
                .init(color: Color.black.opacity(0), location: 0.24),
                .init(color: Color.black.opacity(0), location: 0.45),
                .init(color: Color.black.opacity(0.085), location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .clipShape(backgroundShape)
        .allowsHitTesting(false)
    }

    // Reduced notch/scallop sizes to match this card's smaller rendered width (~52% of the full editable card)
    private var cardNotch: NotchedRectanglePost27 { NotchedRectanglePost27(notchRadius: 30, verticalOffset: 22) }
    private var cardScallop: ScallopedRectangle { ScallopedRectangle(scallopsPerEdge: 30) }

    // Shared by both the shadow (filled) and the gradient overlay (used as a clip shape) so the
    // two always agree on which silhouette - notched, scalloped, or plain rounded - to use.
    private var backgroundShape: AnyShape {
        if passObject.backgroundImage != Data() {
            AnyShape(cardNotch)
        } else if passObject.isCoupon {
            AnyShape(cardScallop)
        } else {
            AnyShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private var imageBackground: some View {
        ZStack {
            // Border - the same photo, tinted darker/lighter, so the border reads as an edge of the
            // actual image instead of a flat, unrelated color.
            cardNotch
                .fill(Color.clear)
                .background(
                    cachedBackgroundImage != nil ?
                        AnyView(
                            Image(uiImage: cachedBackgroundImage!)
                                .resizable()
                                .scaleEffect(1.05)
                                .blur(radius: 6)
                                .overlay(imageBorderTint)
                                .clipShape(cardNotch)
                        )
                        : AnyView(Color.clear)
                )

            // "Real" background
            cardNotch
                .inset(by: 2)
                .fill(Color.clear)
                .background(
                    cachedBackgroundImage != nil ?
                        AnyView(
                            Image(uiImage: cachedBackgroundImage!)
                                .resizable()
                                .scaleEffect(1.05) // Scale up the image slightly to prevent a semitransparent halo around the image
                                .blur(radius: 6)
                                .clipShape(cardNotch.inset(by: 2))
                        )
                        : AnyView(Color.clear)
                )
        }
    }

    private var plainColorBackground: some View {
        ZStack {
            // Border
            RoundedRectangle(cornerRadius: 10)
                .fill(borderColor)

            // "Real" background
            RoundedRectangle(cornerRadius: 10)
                .inset(by: 2)
                .fill(Color(hex: passObject.backgroundColor))
        }
    }

    private var scallopedBackground: some View {
        ZStack {
            // Border
            cardScallop
                .fill(borderColor)

            // "Real" background
            cardScallop
                .inset(by: 2)
                .fill(Color(hex: passObject.backgroundColor))
        }
        // Render this whole subtree into a single cached texture instead of re-rasterizing the ~300-segment scalloped path
        // on every color change. The shape geometry never changes, only the fill/stroke color
        .drawingGroup()
    }

    // A slightly darker (or, for very dark backgrounds, slightly lighter) shade of the pass's own
    // background color, so the plain and scalloped borders read as an edge of the same material
    // instead of an unrelated gray/black outline.
    private var borderColor: Color {
        Color(hex: passObject.backgroundColor).adjustingBrightness(by: passBackgroundBrightness == .veryDark ? 0.15 : -0.12)
    }

    // Darkens (or, for very dark backgrounds, lightens) the border layer's copy of the background
    // photo, so the notched border reads as an edge of the same photo instead of a flat, unrelated
    // color.
    private var imageBorderTint: Color {
        passBackgroundBrightness == .veryDark ? Color.white.opacity(0.18) : Color.black.opacity(0.18)
    }

    // Decodes the background image (if any) for rendering. Brightness is a cheap derived property
    // read straight from `passObject.backgroundBrightness` (see PassObject.swift) — it's precomputed
    // whenever the background is actually changed, so there's nothing to compute here at render time.
    private func decodeBackgroundImage(_ data: Data) {
        cachedBackgroundImage = data == Data() ? nil : UIImage(data: data)
    }

    private var shadowColor: Color {
        switch passBackgroundBrightness {
        case .veryDark:
            return colorScheme == .light ? Color(hex: passObject.backgroundColor) : Color.gray.opacity(0.6)
        case .normal:
            return Color(hex: passObject.backgroundColor)
        case .veryLight:
            return colorScheme == .light ? Color.gray : Color(hex: passObject.backgroundColor).opacity(0.6)
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
}

#Preview {
    PassCard(passObject: MockModelData().passObjects[0])
}
