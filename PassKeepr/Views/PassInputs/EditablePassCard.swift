import PhotosUI
import SwiftUI

struct EditablePassCard: View {
    @State private var photoItem: PhotosPickerItem?
    @Binding var passObject: PassObject
    @State private var scannedCode = ""
    @State private var isCustomizeLogoImagePresented = false
    @State private var isCustomizeBackgroundImagePresented = false
    @State private var isCustomizeBarcodePresented = false
    @State private var isCustomizeQrCodePresented = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(passObject.backgroundImage != Data() ?
                    Color.clear : Color(hex: passObject.backgroundColor)
                )
                .background(
                    Group {
                        if passObject.backgroundImage != Data() {
                            AnyView(
                                Image(uiImage: UIImage(data: passObject.backgroundImage)!)
                                    .resizable()
                                    .scaleEffect(1.1) // Scale up the image slightly so that the clip shape doesn't pick up the white background. Otherwise there will be a white halo on the image
                                    .blur(radius: 6)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 10)
                                    )
                            )
                            .background(Color.clear)
                        } else {
                            AnyView(Color(hex: passObject.backgroundColor).clipShape(
                                RoundedRectangle(cornerRadius: 10)
                            ))
                        }
                    }
                )
                .shadow(color: .gray, radius: 5, x: 0, y: 5)

            if passObject.backgroundImage != Data() {
                VStack {
                    Circle()
                        .foregroundColor(Color(UIColor.secondarySystemBackground)) // Match this to your background color
                        .frame(width: 80) // Adjust to the desired size
                        .offset(y: -65)
                    Spacer()
                }
            }

            if passObject.passType == PassType.barcodePass && passObject.barcodeType == BarcodeType.code128 {
                VStack {
                    Spacer()
                    BuiltInBarcodeView(passObject: $passObject, isCustomizeBarcodePresented: $isCustomizeBarcodePresented)
                }
                .padding([.leading, .trailing], 45)
                .padding(.bottom, 40)
            }

            VStack {
                HStack {
                    ZStack(alignment: .bottomTrailing) {
                        if passObject.logoImage != Data() {
                            Image(uiImage: UIImage(data: passObject.logoImage)!)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 50)
                                .padding(.top, 10)
                                .padding(.leading, 20)
                        } else {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                                .frame(maxHeight: 50)
                                .padding(.top, 10)
                                .padding(.leading, 20)
                                .aspectRatio(3.2, contentMode: .fit)
                        }

                        Button(action: {
                            isCustomizeLogoImagePresented.toggle()
                        }) {
                            Image("custom.photo.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.green, .white)
                                .font(.system(size: 24))
                                .offset(x: 12, y: 12)
                                .shadow(color: .gray, radius: 2, x: 0, y: 0)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .sheet(isPresented: $isCustomizeLogoImagePresented) {
                        CustomizeLogoImage(passObject: $passObject)
                            .edgesIgnoringSafeArea(.bottom)
                            .presentationDragIndicator(.visible)
                    }
                    Spacer()
                }

                if passObject.passType == PassType.barcodePass && passObject.barcodeType != BarcodeType.code128 {
                    StripImageBarcodeView(passObject: $passObject, isCustomizeBarcodePresented: $isCustomizeBarcodePresented)
                }

                EditablePassTextField(textFieldTitle: "NAME", textToEdit: $passObject.passName, textColor: Binding<Color>(
                    get: {
                        Color(hex: passObject.foregroundColor)
                    },
                    set: { newColor in
                        passObject.foregroundColor = newColor.toHex()
                    }
                ), labelColor: Binding<Color>(
                    get: {
                        Color(hex: passObject.labelColor)
                    },
                    set: { newColor in
                        passObject.labelColor = newColor.toHex()
                    }
                ))
                .padding(.leading, 20)

                Spacer()

                if passObject.passType == PassType.qrCodePass {
                    BuiltInQrCodeView(passObject: $passObject, isCustomizeQrCodePresented: $isCustomizeQrCodePresented)
                        .padding([.leading, .trailing], 55)
                        .padding(.bottom, 15)
                        .frame(maxHeight: 170)
                        .sheet(isPresented: $isCustomizeQrCodePresented) {
                            CustomizeQrCode(passObject: $passObject)
                                .edgesIgnoringSafeArea(.bottom)
                                .presentationDragIndicator(.visible)
                        }
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
                    .shadow(color: .gray, radius: 5, x: 0, y: 0)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .sheet(isPresented: $isCustomizeBarcodePresented) {
            CustomizeBarcode(passObject: $passObject)
                .edgesIgnoringSafeArea(.bottom)
                .presentationDragIndicator(.visible)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1 / 1.45, contentMode: .fill)
    }
}

#Preview {
    EditablePassCard(passObject: .constant(MockModelData().passObjects[0]))
}
