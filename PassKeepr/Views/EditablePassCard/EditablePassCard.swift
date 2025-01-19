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

    var body: some View {
        ZStack {
            EditablePassCardBackground(passObject: $passObject)

            VStack {
                EditablePassCardTopSection(passObject: $passObject, isCustomizeLogoImagePresented: $isCustomizeLogoImagePresented)
                    .frame(height: size.height * 0.09) // TODO: Determine the actual height (%) of this
                    .padding([.leading, .trailing], 12)
                    .padding(.top, 6)

                if passObject.passType == PassType.barcodePass && passObject.barcodeType != BarcodeType.code128 {
                    StripImageBarcodeView(passObject: $passObject, isCustomizeBarcodePresented: $isCustomizeBarcodePresented)
                } else {
                    if passObject.isCustomStripImageOn == true {
                        CustomStripImage(passObject: $passObject, isCustomizeStripImagePresented: $isCustomizeStripImagePresented)
                    } else {
                        HStack {
                            PrimaryTextFieldGeneric(textLabel: $passObject.primaryFieldLabel, text: $passObject.primaryFieldText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
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
                    if passObject.isSecondaryFieldOneOn {
                        // These only apply when strip image is on?
                        SecondaryTextField(textLabel: $passObject.secondaryFieldOneLabel, text: $passObject.secondaryFieldOneText, isStripImageOn: passObject.stripImage != Data(), textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                    }

                    Spacer()

                    if passObject.isSecondaryFieldTwoOn {
                        SecondaryTextField(textLabel: $passObject.secondaryFieldTwoLabel, text: $passObject.secondaryFieldTwoText, isStripImageOn: passObject.stripImage != Data(), textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                            .layoutPriority(1)
                    }

                    if passObject.isSecondaryFieldThreeOn {
                        Spacer()

                        SecondaryTextField(textLabel: $passObject.secondaryFieldThreeLabel, text: $passObject.secondaryFieldThreeText, isStripImageOn: passObject.stripImage != Data(), textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                    }
                }
                .padding([.leading, .trailing], 10)
                .layoutPriority(1)
                .frame(width: size.width)
                .frame(height: size.height * 0.068)

                Spacer()

                if passObject.passType == PassType.qrCodePass {
                    BuiltInQrCodeView(passObject: $passObject, isCustomizeQrCodePresented: $isCustomizeQrCodePresented)
                        .frame(height: 170)
                        .sheet(isPresented: $isCustomizeQrCodePresented) {
                            CustomizeQrCode(passObject: $passObject)
                                .edgesIgnoringSafeArea(.bottom)
                                .presentationDragIndicator(.visible)
                        }
                } else if passObject.passType == PassType.barcodePass && passObject.barcodeType == BarcodeType.code128 {
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
    }
}

#Preview {
    EditablePassCard(passObject: .constant(MockModelData().passObjects[0]))
}
