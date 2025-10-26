import KeyboardAware
import PhotosUI
import SwiftUI
import Vision

struct CustomizeQrCode: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var passObject: PassObject
    @State private var photoItem: PhotosPickerItem?
    @State private var imageToScanForQrCodes: UIImage?

    @State private var tempQrCodeData: String = ""
    @State private var tempAltText: String = ""
    @State private var tempBarcodeType: BarcodeType = .code128
    @State private var tempQrCodeCorrectionLevel: QrCodeCorrectionLevel = .quartile
    @State private var tempQrCodeEncoding: QrCodeEncoding = .ascii

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
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Group {
                        if tempQrCodeData != "" {
                            QRCodeView(data: tempQrCodeData, correctionLevel: tempQrCodeCorrectionLevel, encoding: tempQrCodeEncoding).aspectRatio(1, contentMode: .fit)
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
                                    // only allow scanning of qr codes
                                    if BarcodeType.qr != imageBarcode.barcodeType {
                                        showInvalidQrCodeAlert.toggle()
                                    } else {
                                        tempQrCodeData = imageBarcode.payload
                                    }
                                } else {
                                    showInvalidQrCodeAlert.toggle()
                                }
                            }
                        }
                    }

                    Text("Or:")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)

                    TextEditor(text: $tempQrCodeData)
                        .listSectionTextEditorModifier(placeholderText: "QR Code Data", isEnteredTextEmpty: tempQrCodeData.isEmpty)

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
                            passObject.barcodeString = tempQrCodeData
                            passObject.qrCodeCorrectionLevel = tempQrCodeCorrectionLevel
                            passObject.altText = tempAltText
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
            .highPriorityGesture(DragGesture()) // Fix for an iOS 18 bug. Otherwise if you drag with your finger on a button it will click that button. (see https://www.reddit.com/r/SwiftUI/comments/1hf4wwq/sheet_button_triggering_while_scrolling/)
            .background(colorScheme == .light ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
            .alert(isPresented: $showInvalidQrCodeAlert) {
                Alert(title: Text("No valid QR code Detected"),
                      message: Text("Please select an image containing a valid QR code"),
                      dismissButton: .default(Text("OK")))
            }
            .onChange(of: scannedCode) {
                tempQrCodeData = scannedCode
            }
        }
    }
}

#Preview {
    CustomizeQrCode(passObject: .constant(MockModelData().passObjects[0]))
}
