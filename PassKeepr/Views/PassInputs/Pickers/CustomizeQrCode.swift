import KeyboardAware
import PhotosUI
import SwiftUI
import Vision

struct CustomizeQrCode: View {
    @Binding var passObject: PassObject
    @State private var photoItem: PhotosPickerItem?
    @State private var imageToScanForQrCodes: UIImage?

    @State private var tempQrCodeData: String = ""
    @State private var tempAltText: String = ""
    @State private var tempBarcodeType: BarcodeType = .code128
    @State private var tempQrCodeCorrectionLevel: QrCodeCorrectionLevel = .quartile
    @State private var tempQrCodeEncoding: QrCodeEncoding = .ascii

    @State private var scannedCode = ""
    @State private var scannedSymbology: VNBarcodeSymbology?
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
    }

    var body: some View {
        List {
            Section {
                if tempQrCodeData != "" {
                    QRCodeView(data: tempQrCodeData, correctionLevel: tempQrCodeCorrectionLevel, encoding: tempQrCodeEncoding).aspectRatio(1, contentMode: .fit)
                        .onChange(of: tempQrCodeEncoding) {
                            print("qr code encoding \(tempQrCodeEncoding)")
                        }
                } else {
                    Text("Enter QR Code Data")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(20)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            .onChange(of: scannedCode) {
                tempQrCodeData = scannedCode
            }

            Section {
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
                .sheet(isPresented: $isScannerPresented) {
                    ScannerView(scannedData: $scannedCode, scannedSymbology: $scannedSymbology, showScanner: $isScannerPresented)
                        .edgesIgnoringSafeArea(.bottom)
                        .presentationDragIndicator(.visible)
                }
            }
            .listSectionSeparator(.hidden)

            Section {
                Text("Or:")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
            }
            .listSectionSpacing(0)
            .listRowBackground(Color.clear)

            Section {
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
            }
            .onChange(of: photoItem) {
                Task {
                    if let loaded = try? await photoItem?.loadTransferable(type: Data.self) {
                        imageToScanForQrCodes = UIImage(data: loaded)!
                    } else {
                        print("Failed")
                    }
                }
            }
            .onChange(of: imageToScanForQrCodes) {
                Task {
                    if let imageToScanForQrCodes {
                        if let imageBarcode = GetBarcodeFromImage(image: imageToScanForQrCodes) {
                            if BarcodeType.qr != (imageBarcode.symbology.toBarcodeType() ?? BarcodeType.none) {
                                showInvalidQrCodeAlert.toggle()
                            } else {
                                tempQrCodeData = imageBarcode.payload
                            }
                        }
                    }
                }
            }

            Section {
                Text("Or:")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
            }
            .listSectionSpacing(0)
            .listRowBackground(Color.clear)

            Section {
                TextEditor(text: $tempQrCodeData)
                    .overlay(alignment: .topLeading) {
                        if tempQrCodeData.isEmpty {
                            Text("Data")
                                .foregroundColor(.gray.opacity(0.7))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 8)
                                .allowsHitTesting(false)
                        }
                    }

                Picker("Correction Level", selection: $tempQrCodeCorrectionLevel) {
                    ForEach(QrCodeCorrectionLevel.allCases, id: \.self) { level in
                        Text(String(describing: level))
                    }
                }
                .onChange(of: tempQrCodeCorrectionLevel) {
                    scannedSymbology = nil
                }

                Picker("Encoding", selection: $tempQrCodeEncoding) {
                    ForEach(QrCodeEncoding.allCases, id: \.self) { encoding in
                        Text(String(describing: encoding))
                    }
                }
                .onChange(of: tempQrCodeEncoding) {
                    scannedSymbology = nil
                }
            } footer: {
                if scannedSymbology != nil && scannedSymbology != VNBarcodeSymbology.qr {
                    Text("Scanned code is not a valid QR Code")
                }
            }

            Section {
                LabeledContent {
                    TextField("Alt text", text: $tempAltText)
                        .disableAutocorrection(true)
                } label: {
                    Text("Text")
                }
            }

            Section {
                Button(
                    action: {
                        passObject.barcodeString = tempQrCodeData
                        passObject.qrCodeCorrectionLevel = tempQrCodeCorrectionLevel
                        passObject.altText = tempAltText
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Save")
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
            }
            .listRowBackground(Color.accentColor)
        }
        .keyboardAware()
    }
}

#Preview {
    CustomizeQrCode(passObject: .constant(MockModelData().passObjects[0]))
}
