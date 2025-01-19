import PhotosUI
import SwiftUI

struct EditablePassCard: View {
    @State private var photoItem: PhotosPickerItem?
    @Binding var passObject: PassObject
    @State private var size: CGSize = CGSizeZero
    @State private var scannedCode = ""
    @State private var isCustomizeLogoImagePresented = false
    @State private var isCustomizeBackgroundImagePresented = false
    @State private var isCustomizeStripImagePresented = false
    @State private var isCustomizeBarcodePresented = false
    @State private var isCustomizeQrCodePresented = false
    @State private var backgroundBrightness = 0.0
    @State private var placeholderColor = Color.black

    var body: some View {
        ZStack {
            EditablePassCardBackground(passObject: $passObject)

            VStack {
                EditablePassCardTopSection(placeholderColor: placeholderColor, passObject: $passObject, isCustomizeLogoImagePresented: $isCustomizeLogoImagePresented)
                    .frame(height: size.height * 0.09) // TODO: Determine the actual height (%) of this
                    .padding([.leading, .trailing], 12)
                    .padding(.top, 6)

                if passObject.barcodeType != BarcodeType.code128 && passObject.barcodeType != BarcodeType.pdf417 && passObject.barcodeType != BarcodeType.qr && passObject.barcodeType != BarcodeType.none {
                    StripImageBarcodeView(passObject: $passObject, isCustomizeBarcodePresented: $isCustomizeBarcodePresented)
                } else {
                    if passObject.isCustomStripImageOn == true {
                        CustomStripImage(placeholderColor: placeholderColor, passObject: $passObject, isCustomizeStripImagePresented: $isCustomizeStripImagePresented)
                    } else {
                        HStack {
                            PrimaryTextFieldGeneric(placeholderColor: placeholderColor, textLabel: $passObject.primaryFieldLabel, text: $passObject.primaryFieldText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                                .padding([.leading, .trailing], 10)
                                .padding(.top, 14)
                                .frame(maxWidth: size.width) // Must limit this width BEFORE applying .fixedSize, otherwise the parent view will expand if this child view becomes too wide
                                .fixedSize(horizontal: true, vertical: false)
                            Spacer()
                        }
                        .frame(width: size.width)
                        .frame(maxHeight: size.height * 0.1)
                    }
                }

                HStack {
                    // These only apply when strip image is on?
                    SecondaryTextField(placeholderColor: placeholderColor, textLabel: $passObject.secondaryFieldOneLabel, text: $passObject.secondaryFieldOneText, isStripImageOn: passObject.stripImage != Data(), textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))

                    Spacer()

                    if passObject.isSecondaryFieldTwoOn {
                        SecondaryTextField(placeholderColor: placeholderColor, textLabel: $passObject.secondaryFieldTwoLabel, text: $passObject.secondaryFieldTwoText, isStripImageOn: passObject.stripImage != Data(), textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                            .layoutPriority(1)
                    }

                    if passObject.isSecondaryFieldThreeOn {
                        Spacer()

                        SecondaryTextField(placeholderColor: placeholderColor, textLabel: $passObject.secondaryFieldThreeLabel, text: $passObject.secondaryFieldThreeText, isStripImageOn: passObject.stripImage != Data(), textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                    }
                }
                .padding([.leading, .trailing], 10)
                .layoutPriority(1)
                .frame(width: size.width)
                .frame(height: size.height * 0.068)

                Spacer()

                if passObject.barcodeType == BarcodeType.qr {
                    BuiltInQrCodeView(placeholderColor: placeholderColor, passObject: $passObject, isCustomizeQrCodePresented: $isCustomizeQrCodePresented)
                        .frame(height: 170)
                        .sheet(isPresented: $isCustomizeQrCodePresented) {
                            CustomizeQrCode(passObject: $passObject)
                                .edgesIgnoringSafeArea(.bottom)
                                .presentationDragIndicator(.visible)
                        }
                } else if passObject.barcodeType == BarcodeType.code128 || passObject.barcodeType == BarcodeType.pdf417 {
                    BuiltInBarcodeView(passObject: $passObject, isCustomizeBarcodePresented: $isCustomizeBarcodePresented)
                }
            }
            .sheet(isPresented: $isCustomizeBackgroundImagePresented) {
                CustomizeBackgroundImage(passObject: $passObject)
                    .edgesIgnoringSafeArea(.bottom)
                    .presentationDragIndicator(.visible)
            }

            Button(action: {
                isCustomizeBackgroundImagePresented.toggle()
            }) {
                Image("custom.photo.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.green, .white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .font(.system(size: 24))
                    .offset(x: 12, y: 12)
                    .shadow(radius: 5, x: 0, y: 0)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .sheet(isPresented: $isCustomizeBarcodePresented) {
            CustomizeBarcode(passObject: $passObject)
                .edgesIgnoringSafeArea(.bottom)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isCustomizeStripImagePresented) {
            CustomizeStripImage(passObject: $passObject)
                .edgesIgnoringSafeArea(.bottom)
                .presentationDragIndicator(.visible)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1 / 1.45, contentMode: .fill)
        .background(GeometryReader { geometry in // TODO: figure out why readSize can't be used here
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
        backgroundBrightness = ImageRenderer(content: EditablePassCardBackground(passObject: $passObject).frame(width: size.width, height: size.height)).uiImage!.averageBrightness()!

        if backgroundBrightness < 0.2 {
            placeholderColor = Color.gray
        } else if backgroundBrightness > 0.2 && backgroundBrightness < 0.55 {
            placeholderColor = Color.white
        } else {
            placeholderColor = Color.black
        }

        print("Background brightness: \(backgroundBrightness)")
        print("myColor: \(placeholderColor)")
    }
}

#Preview {
    EditablePassCard(passObject: .constant(MockModelData().passObjects[0]))
}
