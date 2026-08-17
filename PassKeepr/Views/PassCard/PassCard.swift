import SwiftUI

struct PassCard: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var passSigner: pkPassSigner
    @State private var size: CGSize = CGSizeZero
    @State private var showAlert = false
    @State private var alertMessage = ""
    var passObject: PassObject

    var body: some View {
        PassCardBackgroundView(passObject: passObject, notchRadius: 30, verticalOffset: 22, scallopsPerEdge: 30)
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
}

#Preview {
    PassCard(passObject: MockModelData().passObjects[0])
}
