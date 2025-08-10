import SwiftUI

struct PassCard: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var passSigner: pkPassSigner
    var passObject: PassObject

    var body: some View {
        GeometryReader { geometry in
            VStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(passObject.backgroundImage != Data() ?
                        Color.clear : Color(hex: passObject.backgroundColor)
                    )
                    .background(
                        passObject.backgroundImage != Data() ?
                            Image(uiImage: UIImage(data: passObject.backgroundImage)!)
                            .resizable()
                            // .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .blur(radius: 6)
                            : nil // No background if image is nil
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                    )
                    .shadow(radius: 3, x: 0, y: 3)
                    .overlay(
                        VStack {
                            PassCardTopSection(passObject: passObject)
                                .frame(height: geometry.size.height * 0.2)
                                .padding(0)

                            if getIsStripImageSupported(passObject: passObject) && passObject.stripImage != Data() {
                                Image(uiImage: UIImage(data: passObject.stripImage)!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .aspectRatio(1125 / 432, contentMode: .fit)
                                    .padding(.top, -10)
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

                                        Text(passObject.primaryFieldText)
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
                                .frame(height: geometry.size.height * 0.1)
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

                                        Text(passObject.secondaryFieldOneText)
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
                                .frame(height: geometry.size.height * 0.1)
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
                                .padding([.leading, .trailing], 20)
                                .padding(.bottom, 15)
                            }
                        }
                    )
            }
            .contextMenu {
                let fileManager = FileManager.default
                let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destinationURL = documentsDirectory.appendingPathComponent("\(passObject.id).pkpass")
                ShareLink(item: destinationURL) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }

                Button(action: {
                    let newPass = passObject.duplicate()
                    modelData.passObjects.append(newPass)
                    modelData.encodePassObjects()

                    if let pkpassDir = generatePass(passObject: newPass) {
                        Task {
                            passSigner.uploadPKPassFile(fileURL: pkpassDir, passUuid: newPass.id)
                        }
                        if passSigner.isDataLoaded == true {
                            passSigner.isDataLoaded = false
                        }
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
        }
    }
}

#Preview {
    PassCard(passObject: MockModelData().passObjects[0])
}
