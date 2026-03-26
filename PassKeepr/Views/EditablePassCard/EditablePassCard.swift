import PhotosUI
import SwiftUI

struct EditablePassCard: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var passObject: PassObject

    var isSigningPass: Bool

    @State private var size: CGSize = CGSizeZero
    @State private var scannedCode = ""
    @State private var isCustomizeLogoImagePresented = false
    @State private var isCustomizeBackgroundImagePresented = false
    @State private var isCustomizeStripImagePresented = false
    @State private var isCustomizeThumbnailImagePresented = false
    @Binding var isCustomizeBarcodePresented: Bool
    @Binding var isCustomizeQrCodePresented: Bool
    @State private var passBackgroundBrightness: BackgroundBrightness = .normal

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

    var body: some View {
        ZStack {
            ZStack {
                EditablePassCardBackground(backgroundImage: passObject.backgroundImage, backgroundColor: passObject.backgroundColor, backgroundBrightness: passBackgroundBrightness)

                VStack(spacing: 0) {
                    EditablePassCardTopSection(backgroundBrightness: passBackgroundBrightness, disableButtons: isSigningPass, passObject: $passObject, isCustomizeLogoImagePresented: $isCustomizeLogoImagePresented)
                        .frame(height: size.height * 0.09)
                        .padding([.leading, .trailing], 12)
                        .padding(.top, 6)
                        .padding(.bottom, 0)

                    Group {
                        if passObject.barcodeType != BarcodeType.code128 && passObject.barcodeType != BarcodeType.pdf417 && passObject.barcodeType != BarcodeType.qr && passObject.barcodeType != BarcodeType.none {
                            StripImageBarcodeView(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, passObject: $passObject, isCustomizeBarcodePresented: $isCustomizeBarcodePresented)
                        } else {
                            if passObject.isCustomStripImageOn && passObject.barcodeType != BarcodeType.qr {
                                CustomStripImage(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, passObject: $passObject, isCustomizeStripImagePresented: $isCustomizeStripImagePresented)
                                    .frame(width: size.width)
                            } else {
                                PrimaryTextFieldGeneric(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, textLabel: $passObject.primaryFieldLabel, text: $passObject.primaryFieldText, passObject: $passObject, isCustomizeThumbnailImagePresented: $isCustomizeThumbnailImagePresented, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                                    .padding([.leading, .trailing], 10)
                                    .frame(maxWidth: size.width, maxHeight: size.height * 0.2)
                            }
                        }
                    }
                    .padding([.top, .bottom], 8)

                    // TODO: The text size for all of these should match while still being as large as possible
                    HStack {
                        SecondaryTextField(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, textLabel: $passObject.secondaryFieldOneLabel, text: $passObject.secondaryFieldOneText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                            .layoutPriority(1)

                        Spacer()

                        if passObject.isSecondaryFieldTwoOn {
                            SecondaryTextField(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, textLabel: $passObject.secondaryFieldTwoLabel, text: $passObject.secondaryFieldTwoText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                                .layoutPriority(1)
                        }

                        if passObject.isSecondaryFieldThreeOn {
                            Spacer()

                            SecondaryTextField(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, textLabel: $passObject.secondaryFieldThreeLabel, text: $passObject.secondaryFieldThreeText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                                .layoutPriority(1)
                        }

                        if passObject.isCustomStripImageOn {
                            AuxiliaryTextField(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, textLabel: $passObject.auxiliaryFieldOneLabel, text: $passObject.auxiliaryFieldOneText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                                .layoutPriority(1)

                            if passObject.isAuxiliaryFieldTwoOn {
                                Spacer()

                                AuxiliaryTextField(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, textLabel: $passObject.auxiliaryFieldTwoLabel, text: $passObject.auxiliaryFieldTwoText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                                    .layoutPriority(1)
                            }

                            if passObject.isAuxiliaryFieldThreeOn {
                                Spacer()

                                AuxiliaryTextField(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, textLabel: $passObject.auxiliaryFieldThreeLabel, text: $passObject.auxiliaryFieldThreeText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                                    .layoutPriority(1)
                            }
                        }
                    }
                    .padding([.leading, .trailing], 14)
                    .layoutPriority(1)
                    .frame(width: size.width, height: size.height * 0.08)
                    .padding([.top, .bottom], 5)

                    if !passObject.isCustomStripImageOn {
                        HStack {
                            AuxiliaryTextField(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, textLabel: $passObject.auxiliaryFieldOneLabel, text: $passObject.auxiliaryFieldOneText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                                .layoutPriority(1)

                            Spacer()

                            if passObject.isAuxiliaryFieldTwoOn {
                                AuxiliaryTextField(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, textLabel: $passObject.auxiliaryFieldTwoLabel, text: $passObject.auxiliaryFieldTwoText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                                    .layoutPriority(1)
                            }

                            if passObject.isAuxiliaryFieldThreeOn {
                                Spacer()

                                AuxiliaryTextField(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, textLabel: $passObject.auxiliaryFieldThreeLabel, text: $passObject.auxiliaryFieldThreeText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                                    .layoutPriority(1)
                            }
                        }
                        .padding([.leading, .trailing], 10)
                        .layoutPriority(1)
                        .frame(width: size.width)
                        .frame(height: size.height * 0.07)
                        .padding(.top, 5)
                    }

                    Spacer()

                    if passObject.barcodeType == BarcodeType.qr {
                        BuiltInQrCodeView(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, passObject: $passObject, isCustomizeQrCodePresented: $isCustomizeQrCodePresented)
                            .frame(height: passObject.altText == "" ? size.height * 0.27 : size.height * 0.29)
                    } else if passObject.barcodeType == BarcodeType.code128 || passObject.barcodeType == BarcodeType.pdf417 {
                        BuiltInBarcodeView(backgroundBrightness: passBackgroundBrightness, disableButton: isSigningPass, passObject: $passObject, isCustomizeBarcodePresented: $isCustomizeBarcodePresented)
                    }
                }
                .sheet(isPresented: $isCustomizeBackgroundImagePresented) {
                    CustomizeBackgroundImage(passObject: $passObject)
                        .edgesIgnoringSafeArea(.bottom)
                }
                .sheet(isPresented: $isCustomizeThumbnailImagePresented) {
                    CustomizeThumbnailImage(passObject: $passObject)
                        .edgesIgnoringSafeArea(.bottom)
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
                    .clipShape(passObject.backgroundImage == Data() ? AnyShape(RoundedRectangle(cornerRadius: 10)) : AnyShape(NotchedRectangle()))
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
        .sheet(isPresented: $isCustomizeStripImagePresented) {
            CustomizeStripImage(passObject: $passObject)
                .edgesIgnoringSafeArea(.bottom)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(PassKitConstants.passAspectRatio, contentMode: .fill)
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
        .onChange(of: passObject.backgroundImage) {
            determineBackgroundColor()
        }
        .onChange(of: passObject.backgroundColor) {
            determineBackgroundColor()
        }
        .onAppear {
            determineBackgroundColor()
        }
    }

    func determineBackgroundColor() {
        let backgroundBrightness: CGFloat = ImageRenderer(content: EditablePassCardBackground(backgroundImage: passObject.backgroundImage, backgroundColor: passObject.backgroundColor, backgroundBrightness: .normal).frame(width: size.width, height: size.height)).uiImage!.averageBrightness()!

        if backgroundBrightness < 0.2 {
            passBackgroundBrightness = .veryDark
        } else if backgroundBrightness > 0.2 && backgroundBrightness < 0.55 {
            passBackgroundBrightness = .normal
        } else {
            passBackgroundBrightness = .veryLight
        }

        // print("Background brightness: \(backgroundBrightness)")
    }
}

#Preview {
    EditablePassCard(passObject: .constant(MockModelData().passObjects[0]), isSigningPass: false, isCustomizeBarcodePresented: .constant(false), isCustomizeQrCodePresented: .constant(false))
}
