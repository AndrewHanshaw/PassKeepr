import PhotosUI
import SwiftUI

struct EditablePassCard: View {
    @Binding var passObject: PassObject

    var isSigningPass: Bool

    @State private var size: CGSize = CGSizeZero
    @State private var scannedCode = ""
    @State private var isCustomizeLogoImagePresented = false
    @State private var isCustomizeBackgroundImagePresented = false
    @State private var isCustomizeStripImagePresented = false
    @State private var isCustomizeBarcodePresented = false
    @State private var isCustomizeQrCodePresented = false
    @State private var placeholderColor = Color.black

    var body: some View {
        ZStack {
            ZStack {
                // Acts as a colored shadow for the passCard background, similar to the effect in the iOS add pass screen
                EditablePassCardBackground(passObject: $passObject)
                    .scaleEffect(0.9, anchor: .bottom)
                    .opacity(0.3)
                    .blur(radius: 8)

                EditablePassCardBackground(passObject: $passObject)

                VStack {
                    EditablePassCardTopSection(placeholderColor: placeholderColor, disableButtons: isSigningPass, passObject: $passObject, isCustomizeLogoImagePresented: $isCustomizeLogoImagePresented)
                        .frame(height: size.height * 0.09) // TODO: Determine the actual height (%) of this
                        .padding([.leading, .trailing], 12)
                        .padding(.top, 6)

                    if passObject.barcodeType != BarcodeType.code128 && passObject.barcodeType != BarcodeType.pdf417 && passObject.barcodeType != BarcodeType.qr && passObject.barcodeType != BarcodeType.none {
                        StripImageBarcodeView(placeholderColor: placeholderColor, disableButton: isSigningPass, passObject: $passObject, isCustomizeBarcodePresented: $isCustomizeBarcodePresented)
                    } else {
                        if passObject.isCustomStripImageOn == true {
                            CustomStripImage(placeholderColor: placeholderColor, disableButton: isSigningPass, passObject: $passObject, isCustomizeStripImagePresented: $isCustomizeStripImagePresented)
                        } else {
                            HStack {
                                PrimaryTextFieldGeneric(placeholderColor: placeholderColor, disableButton: isSigningPass, textLabel: $passObject.primaryFieldLabel, text: $passObject.primaryFieldText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                                    .padding([.leading, .trailing], 10)
                                    .padding(.top, 14)
                                    .frame(maxWidth: size.width) // Must limit this width BEFORE applying .fixedSize, otherwise the parent view will expand if this child view becomes too wide
                                    .fixedSize(horizontal: true, vertical: false)
                                Spacer()
                            }
                            .frame(width: size.width)
                            .frame(maxHeight: size.height * 0.1)
                            .padding(.bottom, 50)
                        }
                    }

                    HStack {
                        // These only apply when strip image is off?
                        // When strip image is on, the text is a little larger for some reason
                        SecondaryTextField(placeholderColor: placeholderColor, disableButton: isSigningPass, textLabel: $passObject.secondaryFieldOneLabel, text: $passObject.secondaryFieldOneText, isStripImageOn: passObject.stripImage != Data() || passObject.isCustomStripImageOn, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))

                        Spacer()

                        if passObject.isSecondaryFieldTwoOn {
                            SecondaryTextField(placeholderColor: placeholderColor, disableButton: isSigningPass, textLabel: $passObject.secondaryFieldTwoLabel, text: $passObject.secondaryFieldTwoText, isStripImageOn: passObject.stripImage != Data() || passObject.isCustomStripImageOn, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                                .layoutPriority(1)
                        }

                        if passObject.isSecondaryFieldThreeOn {
                            Spacer()

                            SecondaryTextField(placeholderColor: placeholderColor, disableButton: isSigningPass, textLabel: $passObject.secondaryFieldThreeLabel, text: $passObject.secondaryFieldThreeText, isStripImageOn: passObject.stripImage != Data() || passObject.isCustomStripImageOn, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                        }
                    }
                    .padding([.leading, .trailing], 10)
                    .layoutPriority(1)
                    .frame(width: size.width)
                    .frame(height: size.height * 0.068)

                    Spacer()

                    if passObject.barcodeType == BarcodeType.qr {
                        BuiltInQrCodeView(placeholderColor: placeholderColor, disableButton: isSigningPass, passObject: $passObject, isCustomizeQrCodePresented: $isCustomizeQrCodePresented)
                            .frame(height: passObject.altText == "" ? size.height * 0.27 : size.height * 0.29)
                            .sheet(isPresented: $isCustomizeQrCodePresented) {
                                CustomizeQrCode(passObject: $passObject)
                                    .edgesIgnoringSafeArea(.bottom)
                            }
                    } else if passObject.barcodeType == BarcodeType.code128 || passObject.barcodeType == BarcodeType.pdf417 {
                        BuiltInBarcodeView(placeholderColor: placeholderColor, disableButton: isSigningPass, passObject: $passObject, isCustomizeBarcodePresented: $isCustomizeBarcodePresented)
                    }
                }
                .sheet(isPresented: $isCustomizeBackgroundImagePresented) {
                    CustomizeBackgroundImage(passObject: $passObject)
                        .edgesIgnoringSafeArea(.bottom)
                }
            }
            .overlay {
                if isSigningPass {
                    ZStack {
                        Rectangle()
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .opacity(0.5)
                        ProgressView()
                            .controlSize(.large)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .clipShape(passObject.backgroundImage == Data() ? AnyShape(RoundedRectangle(cornerRadius: 10)) : AnyShape(NotchedRectangle()))
                    .overlay {
                        VStack(spacing: 8) {
                            Spacer().frame(height: 0)
                            Text("Signing Pass…")
                                .offset(y: 40)
                        }
                        .opacity(0.5)
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
        .sheet(isPresented: $isCustomizeBarcodePresented) {
            CustomizeBarcode(passObject: $passObject)
                .edgesIgnoringSafeArea(.bottom)
        }
        .sheet(isPresented: $isCustomizeStripImagePresented) {
            CustomizeStripImage(passObject: $passObject, placeholderColor: placeholderColor)
                .edgesIgnoringSafeArea(.bottom)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1 / 1.45, contentMode: .fill)
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
        let backgroundBrightness: CGFloat = ImageRenderer(content: EditablePassCardBackground(passObject: $passObject).frame(width: size.width, height: size.height)).uiImage!.averageBrightness()!

        if backgroundBrightness < 0.2 {
            placeholderColor = Color.gray
        } else if backgroundBrightness > 0.2 && backgroundBrightness < 0.55 {
            placeholderColor = Color.white
        } else {
            placeholderColor = Color.black
        }

//        print("Background brightness: \(backgroundBrightness)")
//        print("myColor: \(placeholderColor)")
    }
}

#Preview {
    EditablePassCard(passObject: .constant(MockModelData().passObjects[0]), isSigningPass: false)
}
