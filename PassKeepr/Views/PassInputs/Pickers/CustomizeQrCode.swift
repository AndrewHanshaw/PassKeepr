import KeyboardAware
import PhotosUI
import SwiftUI
import Vision

struct CustomizeQrCode: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var passObject: PassObject
    @State private var photoItem: PhotosPickerItem?

    @State private var tempQrCodeData: String = ""
    @State private var tempAltText: String = ""
    @State private var tempBarcodeType: BarcodeType = .code128
    @State private var tempQrCodeCorrectionLevel: QrCodeCorrectionLevel = .quartile
    @State private var tempQrCodeEncoding: QrCodeEncoding = .ascii
    @State private var tempQrCodeType: QrCodeType = .standard
    @State private var tempPassObject: PassObject

    @State private var scannedCode = ""
    @State private var scannedBarcodeType: BarcodeType?
    @State private var isScannerPresented = false
    @State private var useScannedData = false
    @State private var showAlert: Bool = false
    @State private var showInvalidQrCodeAlert: Bool = false

    @Environment(\.displayScale) var displayScale
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(passObject: Binding<PassObject>) {
        _passObject = passObject
        _tempQrCodeData = State(initialValue: passObject.wrappedValue.barcodeString)
        _tempAltText = State(initialValue: passObject.wrappedValue.altText)
        _tempQrCodeCorrectionLevel = State(initialValue: passObject.wrappedValue.qrCodeCorrectionLevel)
        _tempQrCodeEncoding = State(initialValue: passObject.wrappedValue.qrCodeEncoding)
        _tempQrCodeType = State(initialValue: passObject.wrappedValue.qrCodeType)
        _tempPassObject = State(initialValue: passObject.wrappedValue)
    }

    var currentQrString: String {
        switch tempQrCodeType {
        case .standard:
            return tempQrCodeData
        case .wifi:
            guard !tempPassObject.wifiSSID.isEmpty else { return "" }
            return WifiQrCode.formatWifi(from: tempPassObject)
        case .vcard:
            let hasContent = [
                tempPassObject.vcardFirstName, tempPassObject.vcardLastName,
                tempPassObject.vcardCompany, tempPassObject.vcardPhone,
                tempPassObject.vcardEmail,
            ].contains { !$0.isEmpty }
            guard hasContent else { return "" }
            return VCardQrCode.formatVCard(from: tempPassObject)
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Group {
                        if currentQrString != "" {
                            QRCodeView(data: currentQrString, correctionLevel: tempQrCodeCorrectionLevel, encoding: tempQrCodeEncoding).aspectRatio(1, contentMode: .fit)
                                .onChange(of: tempQrCodeEncoding) {
                                    print("qr code encoding \(tempQrCodeEncoding)")
                                }
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                                    .aspectRatio(1, contentMode: .fit)
                                    .foregroundColor(Color.gray)
                                    .opacity(0.5)
                                Text("Enter QR Code Data")
                                    .foregroundColor(Color.gray)
                                    .opacity(0.7)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .clipShape(.rect(cornerRadius: 5))
                    .padding([.leading, .trailing], 80)
                    .padding([.top, .bottom], 10)

                    Button(
                        action: { isScannerPresented.toggle() },
                        label: {
                            HStack {
                                Image(systemName: "qrcode.viewfinder")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(.label))

                                Text("Scan Existing QR Code")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(.label))
                                    .disabled(false)
                            }
                            .padding([.top, .bottom], 10)
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    )
                    .listSectionBackgroundModifier()
                    .sheet(isPresented: $isScannerPresented) {
                        ScannerView(scannedData: $scannedCode, scannedBarcodeType: $scannedBarcodeType, showScanner: $isScannerPresented)
                            .edgesIgnoringSafeArea(.bottom)
                    }

                    Text("Or:")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)

                    PhotosPicker(selection: $photoItem, matching: .any(of: [.images, .not(.videos)])) {
                        HStack {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(Color(.label))

                            Text("Get QR Code from Image")
                                .font(.system(size: 20))
                                .foregroundColor(Color(.label))
                                .disabled(false)
                        }
                        .padding([.top, .bottom], 10)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .listSectionBackgroundModifier()
                    .onChange(of: photoItem) {
                        Task {
                            if let loaded = try? await photoItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: loaded) {
                                if let imageBarcode = GetBarcodeFromImage(image: image) {
                                    if BarcodeType.qr != imageBarcode.barcodeType {
                                        showInvalidQrCodeAlert.toggle()
                                    } else {
                                        applyScannedCode(imageBarcode.payload)
                                    }
                                } else {
                                    showInvalidQrCodeAlert.toggle()
                                }
                            } else {
                                showInvalidQrCodeAlert.toggle()
                            }
                        }
                    }

                    Text("Or:")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)

                    HStack {
                        Text("Type")
                        Spacer()
                        Picker("QR Code Type", selection: $tempQrCodeType) {
                            ForEach(QrCodeType.allCases, id: \.self) { type in
                                Text(String(describing: type))
                            }
                        }
                        .accentColor(.secondary)
                    }
                    .padding([.top, .bottom], 10)
                    .padding(.trailing, 4)
                    .padding(.leading, 12)
                    .listSectionBackgroundModifier()
                    .onChange(of: tempQrCodeType) {
                        tempQrCodeData = ""
                    }

                    switch tempQrCodeType {
                    case .standard:
                        LabeledContent {
                            TextField("QR Code Data", text: $tempQrCodeData, axis: .vertical)
                                .keyboardType(tempBarcodeType.keyboardType())
                                .disableAutocorrection(true)
                                .lineLimit(1 ... 20)
                        } label: {
                            Text("Data")
                        }
                        .padding(16)
                        .listSectionBackgroundModifier()
                    case .wifi:
                        WifiQrCode(passObject: $tempPassObject)
                    case .vcard:
                        VCardQrCode(passObject: $tempPassObject)
                    }

                    HStack {
                        Text("Correction Level")
                        Spacer()
                        Picker("Correction Level", selection: $tempQrCodeCorrectionLevel) {
                            ForEach(QrCodeCorrectionLevel.allCases, id: \.self) { level in
                                Text(String(describing: level))
                            }
                        }
                        .accentColor(.secondary)
                    }
                    .padding([.top, .bottom], 10)
                    .padding(.trailing, 4)
                    .padding(.leading, 12)
                    .listSectionBackgroundModifier()
                    .onChange(of: tempQrCodeCorrectionLevel) {
                        scannedBarcodeType = nil
                    }

                    if tempQrCodeType == .standard {
                        HStack {
                            Text("Encoding")
                            Spacer()
                            Picker("Encoding", selection: $tempQrCodeEncoding) {
                                ForEach(QrCodeEncoding.allCases, id: \.self) { encoding in
                                    Text(String(describing: encoding))
                                }
                            }
                            .accentColor(.secondary)
                        }
                        .padding([.top, .bottom], 10)
                        .padding(.trailing, 4)
                        .padding(.leading, 12)
                        .listSectionBackgroundModifier()
                        .onChange(of: tempQrCodeEncoding) {
                            scannedBarcodeType = nil
                        }
                    }

                    LabeledContent {
                        TextField("Alt text", text: $tempAltText)
                            .disableAutocorrection(true)
                    } label: {
                        Text("Text")
                    }
                    .padding(14)
                    .listSectionBackgroundModifier()

                    Spacer()
                }
                .padding(.top, 60)
                .padding()
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Customize QR Code")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", systemImage: "checkmark") {
                            var saved = tempPassObject
                            saved.barcodeString = currentQrString
                            saved.qrCodeCorrectionLevel = tempQrCodeCorrectionLevel
                            saved.qrCodeEncoding = tempQrCodeEncoding
                            saved.qrCodeType = tempQrCodeType
                            saved.altText = tempAltText
                            passObject = saved
                            presentationMode.wrappedValue.dismiss()
                        }
                        .toolbarConfirmButtonModifier()
                    }

                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .toolbarCancelButtonModifier()
                    }
                }
            }
            .keyboardAware()
            .scrollDismissesKeyboard(.immediately)
            .ignoresSafeArea(edges: .all) // otherwise it gets all wiggy when you flick scroll to the top or bottom
            .highProrityDragGestureModifier()
            .background(colorScheme == .light ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
            .alert(isPresented: $showInvalidQrCodeAlert) {
                Alert(title: Text("No Valid QR Code Detected"),
                      message: Text("Please select an image containing a valid QR code"),
                      dismissButton: .default(Text("OK")))
            }
            .onChange(of: scannedCode) {
                applyScannedCode(scannedCode)
            }
        }
    }

    private func applyScannedCode(_ code: String) {
        let upper = code.uppercased()
        if upper.hasPrefix("WIFI:") {
            tempQrCodeType = .wifi
            let p = WifiQrCode.parseWifi(code)
            tempPassObject.wifiSSID = p.ssid
            tempPassObject.wifiPassword = p.password
            tempPassObject.wifiSecurity = p.security
            tempPassObject.wifiIsHidden = p.isHidden
        } else if upper.contains("BEGIN:VCARD") {
            tempQrCodeType = .vcard
            VCardQrCode.applyParsed(code, to: &tempPassObject)
        } else {
            tempQrCodeType = .standard
            tempQrCodeData = code
        }
    }
}

#Preview {
    CustomizeQrCode(passObject: .constant(MockModelData().passObjects[0]))
}
