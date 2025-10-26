import KeyboardAware
import PhotosUI
import SwiftUI
import Vision

struct CustomizeBarcode: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var passObject: PassObject
    @State private var photoItem: PhotosPickerItem?
    @State private var imageToScanForBarcodes: UIImage?

    @State private var tempBarcodeData = ""
    @State private var tempAltText = ""
    @State private var tempBarcodeType: BarcodeType
    @State private var tempBarcodeBorder: Double
    @State private var tempStripImage: Data

    @State private var scannedCode: String = ""
    @State private var scannedBarcodeType: BarcodeType?
    @State private var isScannerPresented = false
    @State private var useScannedData = false
    @State private var showAlert: Bool = false
    @State private var showInvalidBarcodeAlert: Bool = false

    @Environment(\.displayScale) var displayScale
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(passObject: Binding<PassObject>) {
        _passObject = passObject
        _tempBarcodeData = State(initialValue: passObject.wrappedValue.barcodeString)
        _tempAltText = State(initialValue: passObject.wrappedValue.altText)
        _tempBarcodeType = State(initialValue: passObject.wrappedValue.barcodeType)
        _tempBarcodeBorder = State(initialValue: passObject.wrappedValue.barcodeBorder)
        _tempStripImage = State(initialValue: passObject.wrappedValue.stripImage)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Group {
                        if tempBarcodeType.isEnteredBarcodeValueValid(string: tempBarcodeData) {
                            switch tempBarcodeType {
                            case BarcodeType.none:
                                EmptyView()

                            case BarcodeType.code39:
                                Code39View(value: $tempBarcodeData, border: tempBarcodeBorder).aspectRatio(1125.0 / 432.0, contentMode: .fit)
                                    .frame(maxWidth: .infinity)

                            case BarcodeType.code93:
                                Code93View(value: $tempBarcodeData, border: tempBarcodeBorder)
                                    .aspectRatio(1125.0 / 432.0, contentMode: .fit)
                                    .frame(maxWidth: .infinity)

                            case BarcodeType.upce:
                                UPCEView(value: $tempBarcodeData, border: tempBarcodeBorder)
                                    .aspectRatio(1125.0 / 432.0, contentMode: .fit)
                                    .frame(maxWidth: .infinity)

                            case BarcodeType.upca:
                                UPCAView(value: $tempBarcodeData, border: tempBarcodeBorder)
                                    .aspectRatio(1125.0 / 432.0, contentMode: .fit)
                                    .frame(maxWidth: .infinity)

                            case BarcodeType.ean13:
                                EAN13View(value: $tempBarcodeData, border: tempBarcodeBorder)
                                    .aspectRatio(1125.0 / 432.0, contentMode: .fit)
                                    .frame(maxWidth: .infinity)

                            case BarcodeType.code128:
                                Code128View(data: tempBarcodeData)
                                    .aspectRatio(1125.0 / 432.0, contentMode: .fit)
                                    .frame(maxWidth: .infinity)

                            case BarcodeType.pdf417:
                                PDF417View(data: tempBarcodeData)
                                    .aspectRatio(1125.0 / 432.0, contentMode: .fit)
                                    .frame(maxWidth: .infinity)

                            case BarcodeType.qr:
                                EmptyView()
                            }
                        } else {
                            InvalidBarcodeView(isEmpty: tempBarcodeData == "")
                                .aspectRatio(1125.0 / 432.0, contentMode: .fit)
                        }
                    }
                    .padding(.bottom, 20)
                    .padding(.top, 10)

                    Button(
                        action: { isScannerPresented.toggle() },
                        label: {
                            HStack {
                                Image(systemName: "barcode.viewfinder")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(.label))

                                Text("Scan Existing Barcode")
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
                    .onChange(of: tempBarcodeBorder) {
                        render()
                    }
                    .onChange(of: scannedCode) {
                        guard !scannedCode.isEmpty else { return }
                        tempBarcodeData = scannedCode

                        // Do not support converting a barcode pass to a qr code pass
                        if scannedBarcodeType != BarcodeType.qr {
                            tempBarcodeType = scannedBarcodeType ?? BarcodeType.code128
                        }

                        scannedCode = "" // allows for repeated scanning of the same code
                    }
                    .onChange(of: tempBarcodeData) {
                        render()
                    }
                    .onChange(of: tempBarcodeType) {
                        render()
                    }
                    .onAppear { render() }

                    Text("Or:")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)

                    PhotosPicker(selection: $photoItem, matching: .any(of: [.images, .not(.videos)])) {
                        HStack {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(Color(.label))

                            Text("Get Barcode from Image")
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
                                imageToScanForBarcodes = UIImage(data: loaded)!
                            } else {
                                print("Failed")
                            }
                        }
                    }
                    .onChange(of: imageToScanForBarcodes) {
                        Task {
                            if let imageToScanForBarcodes {
                                if let imageBarcode = GetBarcodeFromImage(image: imageToScanForBarcodes) {
                                    switch imageBarcode.barcodeType {
                                    case BarcodeType.code128, BarcodeType.code93, BarcodeType.code39, BarcodeType.upce, BarcodeType.pdf417, BarcodeType.ean13, BarcodeType.upca:
                                        tempBarcodeData = imageBarcode.payload
                                        tempBarcodeType = imageBarcode.barcodeType
                                    default:
                                        showInvalidBarcodeAlert.toggle()
                                    }
                                } else {
                                    showInvalidBarcodeAlert.toggle()
                                }
                            }
                        }
                    }

                    Text("Or:")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)

                    VStack {
                        HStack {
                            Text("Barcode Type")
                            Spacer()
                            Picker("Barcode Type", selection: $tempBarcodeType) {
                                ForEach(BarcodeType.allCases, id: \.self) { type in
                                    if type != BarcodeType.qr && type != BarcodeType.none {
                                        Text(String(describing: type))
                                            .frame(maxWidth: 60)
                                    }
                                }
                            }
                            .accentColor(.secondary)
                            .padding(.trailing, 12)
                        }
                        .overlay(
                            HStack {
                                Spacer()
                                Button(
                                    action: {
                                        showAlert.toggle()
                                    },
                                    label: {
                                        Image(systemName: "info.circle")
                                            .foregroundColor(Color(.label))
                                    }
                                )
                                .buttonStyle(PlainButtonStyle())
                            }
                        )
                        .layoutPriority(1)
                        .padding(.top, 14)
                        .padding(.bottom, 7)
                        .overlay(Divider().padding([.leading, .trailing], 2), alignment: .bottom)
                        .padding([.leading, .trailing], 14)

                        if tempBarcodeType != BarcodeType.none {
                            LabeledContent {
                                TextField("Barcode Data", text: $tempBarcodeData)
                                    .keyboardType(tempBarcodeType.keyboardType())
                                    .disableAutocorrection(true)
                                    .keyboardType(.asciiCapable)
                            } label: {
                                Text("Data")
                            }
                            .padding([.top], 7)
                            .padding([.leading, .trailing, .bottom], 16)
                        }
                    }
                    .listSectionBackgroundModifier()

                    if tempBarcodeType == BarcodeType.code128 || tempBarcodeType == BarcodeType.pdf417 {
                        LabeledContent {
                            TextField("Alt text", text: $tempAltText)
                                .disableAutocorrection(true)
                        } label: {
                            Text("Alt Text")
                        }
                        .padding(14)
                        .listSectionBackgroundModifier()
                    } else if tempBarcodeType != BarcodeType.none {
                        HStack {
                            Text("Border")
                            Slider(value: $tempBarcodeBorder, in: 0 ... 0.1, step: 0.005) {
                                Text("Border")
                            }
                        }
                        .padding(14)
                        .listSectionBackgroundModifier()
                    }
                }
                .padding(.top, 60)
                .padding()
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Customize Barcode")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", systemImage: "checkmark") {
                            passObject.barcodeString = tempBarcodeData
                            passObject.altText = tempAltText
                            passObject.barcodeType = tempBarcodeType
                            passObject.barcodeBorder = tempBarcodeBorder
                            if tempBarcodeType.doesBarcodeUseStripImage() {
                                passObject.stripImage = tempStripImage
                            }
                            if tempStripImage != Data() {
                                passObject.backgroundImage = Data()
                            }
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
//            .highPriorityGesture(DragGesture()) // Would use this like we do in CustomizeQRCode but it breaks the Sliders.
            .background(colorScheme == .light ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
            .alert(isPresented: $showAlert) {
                Alert(title: Text(String(describing: tempBarcodeType)),
                      message: Text(tempBarcodeType.info()),
                      dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showInvalidBarcodeAlert) {
                Alert(title: Text("No valid barcode Detected"),
                      message: Text("Please select an image containing a valid barcode"),
                      dismissButton: .default(Text("OK")))
            }
        }
    }

    @MainActor func render() {
        // Strip image size according to
        // https://help.passkit.com/en/articles/2214902-what-are-the-optimum-image-sizes
        // (Seems to be accurate)
        let imageWidth = 1125.0
        let imageHeight = 432.0

        switch tempBarcodeType {
        case BarcodeType.code39:
            tempStripImage = ImageRenderer(content:
                Code39View(value: $tempBarcodeData, border: tempBarcodeBorder).frame(width: imageWidth, height: imageHeight)
            ).uiImage?.pngData() ?? Data()

        case BarcodeType.code93:
            tempStripImage = ImageRenderer(content:
                Code93View(value: $tempBarcodeData, border: tempBarcodeBorder).frame(width: imageWidth, height: imageHeight)
            ).uiImage?.pngData() ?? Data()

        case BarcodeType.upce:
            tempStripImage = ImageRenderer(content:
                UPCEView(value: $tempBarcodeData, border: tempBarcodeBorder).frame(width: imageWidth, height: imageHeight)
            ).uiImage?.pngData() ?? Data()

        case BarcodeType.upca:
            tempStripImage = ImageRenderer(content:
                UPCAView(value: $tempBarcodeData, border: tempBarcodeBorder).frame(width: imageWidth, height: imageHeight)
            ).uiImage?.pngData() ?? Data()

        default:
            break
        }
    }
}

#Preview {
    CustomizeBarcode(passObject: .constant(MockModelData().passObjects[0]))
}
