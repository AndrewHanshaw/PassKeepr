import SwiftUI

struct PassCard: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var passSigner: pkPassSigner
    @State private var size: CGSize = CGSizeZero
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSigningForShare = false
    @State private var shareURL: URL? = nil
    @State private var showShareSheet = false
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
                Button(action: {
                    preparePassForShare()
                }) {
                    if isSigningForShare {
                        Label("Signing...", systemImage: "hourglass")
                    } else {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
                .disabled(isSigningForShare)

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
            .sheet(isPresented: $showShareSheet) {
                if let shareURL = shareURL {
                    ActivityView(activityItems: [shareURL])
                }
            }
            .onChange(of: passSigner.isDataLoaded) { _, newValue in
                if newValue && isSigningForShare {
                    shareURL = passSigner.fileURL
                    showShareSheet = true
                    isSigningForShare = false
                    passSigner.isDataLoaded = false // Reset for next share
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
    }

    private func preparePassForShare() {
        isSigningForShare = true
        alertMessage = ""

        // Clean up old files before generating new ones
        let fileManager = FileManager.default
        let appSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let oldPkpassURL = appSupportDirectory.appendingPathComponent("\(passObject.id).pkpass")
        let oldPassDirectory = appSupportDirectory.appendingPathComponent("\(passObject.id).pass")

        do {
            // Remove old pkpass file if it exists
            if fileManager.fileExists(atPath: oldPkpassURL.path) {
                try fileManager.removeItem(at: oldPkpassURL)
            }
            // Remove old pass directory if it exists
            if fileManager.fileExists(atPath: oldPassDirectory.path) {
                try fileManager.removeItem(at: oldPassDirectory)
            }
        } catch {
            alertMessage = "Failed to clean up old pass files: \(error.localizedDescription)"
            showAlert = true
            isSigningForShare = false
            return
        }

        // Generate the unsigned pass
        guard let passDirectory = generatePass(passObject: passObject) else {
            alertMessage = "Failed to generate pass file"
            showAlert = true
            isSigningForShare = false
            return
        }

        // Upload for signing
        Task {
            passSigner.uploadPKPassFile(fileURL: passDirectory, passUuid: passObject.id)
        }
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
    PassCard(passObject: MockModelData().passObjects[0])
}
