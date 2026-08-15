import PhotosUI
import SwiftUI

struct EditablePassCard: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var passObject: PassObject

    var isSigningPass: Bool

    @State private var scannedCode = ""
    @Binding var isCustomizeLogoImagePresented: Bool
    @Binding var isCustomizeBackgroundImagePresented: Bool
    @Binding var isCustomizeStripImagePresented: Bool
    @Binding var isCustomizeThumbnailImagePresented: Bool
    @Binding var isCustomizeBarcodePresented: Bool
    @Binding var isCustomizeQrCodePresented: Bool

    // Brightness is precomputed on PassObject whenever the background image/color is actually changed,
    // so this just reads it directly, no local state or offscreen rendering needed here.
    private var passBackgroundBrightness: BackgroundBrightness { passObject.backgroundBrightness }

    private var signingOverlayColor: Color {
        switch passBackgroundBrightness {
        case .veryLight:
            return colorScheme == .light ? Color.black.opacity(0.05) : Color.black.opacity(0.3)
        case .normal:
            return colorScheme == .light ? Color.white.opacity(0.5) : Color.black.opacity(0.5)
        case .veryDark:
            return colorScheme == .light ? Color.white.opacity(0.5) : Color.white.opacity(0.2)
        }
    }

    private var signingContentColor: Color {
        switch passBackgroundBrightness {
        case .veryLight:
            return colorScheme == .light ? Color.gray : Color.white
        default:
            return colorScheme == .light ? Color.white : Color.white
        }
    }

    // Mirrors the shape selection in EditablePassCardBackgroundPost27: a notched card when there's
    // a background image, a scalloped (coupon) edge when there isn't one but isCoupon is set, and a
    // plain rounded rectangle otherwise.
    private var signingOverlayClipShapePost27: AnyShape {
        if passObject.backgroundImage != Data() {
            AnyShape(NotchedRectanglePost27())
        } else if passObject.isCoupon {
            AnyShape(ScallopedRectangle())
        } else {
            AnyShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    // Mirrors the shape selection in EditablePassCardBackground (pre-iOS 27 equivalent of the above).
    private var signingOverlayClipShapePreiOS27: AnyShape {
        if passObject.backgroundImage != Data() {
            AnyShape(NotchedRectangle())
        } else if passObject.isCoupon {
            AnyShape(ScallopedRectangle())
        } else {
            AnyShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    var body: some View {
        // Deriving `size` directly from the GeometryReader's own proposed size (rather than
        // measuring the rendered content after the fact via .background + @State) means there's
        // no stale-state round trip: the aspectRatio(.fit) modifier constrains the size proposed
        // to this GeometryReader, so `geometry.size` is already correct on every layout pass,
        // including the very first one.
        GeometryReader { geometry in
            cardContent(size: geometry.size)
        }
        .aspectRatio(PassKitConstants.passAspectRatio, contentMode: .fit)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func cardContent(size: CGSize) -> some View {
        ZStack {
            ZStack {
                EditablePassCardBackground(backgroundImage: passObject.backgroundImage, backgroundColor: passObject.backgroundColor, backgroundBrightness: passBackgroundBrightness, isCoupon: passObject.isCoupon)

                VStack(spacing: 0) {
                    EditablePassCardTopSection(backgroundBrightness: passBackgroundBrightness, disableButtons: isSigningPass, passObject: $passObject, isCustomizeLogoImagePresented: $isCustomizeLogoImagePresented)
                        .frame(height: size.height * 0.09)
                        .padding(.horizontal, 12)
                        .padding(.top, 6)
                        .padding(.bottom, 0)
                        .zIndex(1)

                    Group {
                        if passObject.barcodeType != BarcodeType.code128 && passObject.barcodeType != BarcodeType.pdf417 && passObject.barcodeType != BarcodeType.qr && passObject.barcodeType != BarcodeType.none {
                            StripImageBarcodeView(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, passObject: $passObject, isCustomizeBarcodePresented: $isCustomizeBarcodePresented)
                        } else {
                            if passObject.isCustomStripImageOn {
                                CustomStripImage(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, passObject: $passObject, isCustomizeStripImagePresented: $isCustomizeStripImagePresented)
                                    .frame(width: size.width)
                            } else {
                                PrimaryTextFieldGeneric(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, textLabel: $passObject.primaryFieldLabel, text: $passObject.primaryFieldText, passObject: $passObject, isCustomizeThumbnailImagePresented: $isCustomizeThumbnailImagePresented, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                                    .padding(.horizontal, 10)
                                    .frame(maxWidth: size.width, maxHeight: size.height * 0.2)
                            }
                        }
                    }
                    .padding(.vertical, 8)

                    // TODO: The text size for all of these should match while still being as large as possible
                    HStack {
                        SecondaryTextField(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, textLabel: $passObject.secondaryFieldOneLabel, text: $passObject.secondaryFieldOneText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor), isCurrency: passObject.isCurrencyFieldsOn && passObject.isSecondaryFieldOneCurrency, currencyCode: passObject.currencyCode)
                            .layoutPriority(1)

                        Spacer()

                        if passObject.isSecondaryFieldTwoOn {
                            SecondaryTextField(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, textLabel: $passObject.secondaryFieldTwoLabel, text: $passObject.secondaryFieldTwoText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor), isCurrency: passObject.isCurrencyFieldsOn && passObject.isSecondaryFieldTwoCurrency, currencyCode: passObject.currencyCode)
                                .layoutPriority(1)
                        }

                        if passObject.isSecondaryFieldThreeOn {
                            Spacer()

                            SecondaryTextField(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, textLabel: $passObject.secondaryFieldThreeLabel, text: $passObject.secondaryFieldThreeText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor), isCurrency: passObject.isCurrencyFieldsOn && passObject.isSecondaryFieldThreeCurrency, currencyCode: passObject.currencyCode)
                                .layoutPriority(1)
                        }

                        if passObject.isCustomStripImageOn {
                            if passObject.isAuxiliaryFieldOneOn {
                                AuxiliaryTextField(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, textLabel: $passObject.auxiliaryFieldOneLabel, text: $passObject.auxiliaryFieldOneText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor), isCurrency: passObject.isCurrencyFieldsOn && passObject.isAuxiliaryFieldOneCurrency, currencyCode: passObject.currencyCode)
                                    .layoutPriority(1)
                            }

                            if passObject.isAuxiliaryFieldTwoOn {
                                Spacer()

                                AuxiliaryTextField(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, textLabel: $passObject.auxiliaryFieldTwoLabel, text: $passObject.auxiliaryFieldTwoText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor), isCurrency: passObject.isCurrencyFieldsOn && passObject.isAuxiliaryFieldTwoCurrency, currencyCode: passObject.currencyCode)
                                    .layoutPriority(1)
                            }

                            if passObject.isAuxiliaryFieldThreeOn {
                                Spacer()

                                AuxiliaryTextField(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, textLabel: $passObject.auxiliaryFieldThreeLabel, text: $passObject.auxiliaryFieldThreeText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor), isCurrency: passObject.isCurrencyFieldsOn && passObject.isAuxiliaryFieldThreeCurrency, currencyCode: passObject.currencyCode)
                                    .layoutPriority(1)
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .layoutPriority(1)
                    .frame(width: size.width, height: size.height * 0.08)
                    .padding(.vertical, 5)

                    if !passObject.isCustomStripImageOn {
                        HStack {
                            if passObject.isAuxiliaryFieldOneOn {
                                AuxiliaryTextField(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, textLabel: $passObject.auxiliaryFieldOneLabel, text: $passObject.auxiliaryFieldOneText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor), isCurrency: passObject.isCurrencyFieldsOn && passObject.isAuxiliaryFieldOneCurrency, currencyCode: passObject.currencyCode)
                                    .layoutPriority(1)
                            }

                            Spacer()

                            if passObject.isAuxiliaryFieldTwoOn {
                                AuxiliaryTextField(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, textLabel: $passObject.auxiliaryFieldTwoLabel, text: $passObject.auxiliaryFieldTwoText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor), isCurrency: passObject.isCurrencyFieldsOn && passObject.isAuxiliaryFieldTwoCurrency, currencyCode: passObject.currencyCode)
                                    .layoutPriority(1)
                            }

                            if passObject.isAuxiliaryFieldThreeOn {
                                Spacer()

                                AuxiliaryTextField(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, textLabel: $passObject.auxiliaryFieldThreeLabel, text: $passObject.auxiliaryFieldThreeText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor), isCurrency: passObject.isCurrencyFieldsOn && passObject.isAuxiliaryFieldThreeCurrency, currencyCode: passObject.currencyCode)
                                    .layoutPriority(1)
                            }
                        }
                        .padding(.horizontal, 10)
                        .layoutPriority(1)
                        .frame(width: size.width)
                        .frame(height: size.height * 0.07)
                        .padding(.top, 5)
                    }

                    Spacer()

                    if passObject.barcodeType == BarcodeType.qr {
                        BuiltInQrCodeView(disableButton: isSigningPass, passObject: $passObject, isCustomizeQrCodePresented: $isCustomizeQrCodePresented)
                            .frame(height: passObject.altText == "" ? size.height * 0.32 : size.height * 0.36)
                    } else if passObject.barcodeType == BarcodeType.code128 || passObject.barcodeType == BarcodeType.pdf417 {
                        BuiltInBarcodeView(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, passObject: $passObject, isCustomizeBarcodePresented: $isCustomizeBarcodePresented)
                    }
                }
            }
            .overlay {
                if isSigningPass {
                    ZStack {
                        Rectangle()
                            .foregroundStyle(signingOverlayColor)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        ProgressView()
                            .controlSize(.large)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .tint(signingContentColor)
                            .foregroundColor(signingContentColor)
                    }
                    .clipShape(signingOverlayClipShapePreiOS27)
                    .overlay {
                        VStack(spacing: 8) {
                            Spacer().frame(height: 0)
                            Text("Signing Pass…")
                                .offset(y: 40)
                                .foregroundColor(signingContentColor)
                                .fontWeight(.semibold)
                        }
                        .opacity(0.9)
                    }
                }
            }
            .overlay {
                if passObject.stripImage == Data() && !passObject.isCustomStripImageOn {
                    Button(action: {
                        isCustomizeBackgroundImagePresented.toggle()
                    }) {
                        Image("custom.photo.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.green, .white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            .font(.system(size: 28))
                            .offset(x: 12, y: 12)
                            .shadow(radius: 5, x: 0, y: 0)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isSigningPass)
                }
            }
        }
    }
}

#Preview {
    EditablePassCard(passObject: .constant(MockModelData().passObjects[0]), isSigningPass: false, isCustomizeLogoImagePresented: .constant(false), isCustomizeBackgroundImagePresented: .constant(false), isCustomizeStripImagePresented: .constant(false), isCustomizeThumbnailImagePresented: .constant(false), isCustomizeBarcodePresented: .constant(false), isCustomizeQrCodePresented: .constant(false))
}
