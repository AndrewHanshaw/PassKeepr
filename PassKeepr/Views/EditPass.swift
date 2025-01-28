import SwiftUI

struct EditPass: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var passSigner: pkPassSigner

    // Pass object passed into this view.
    // We want to update this object when the save button is pressed
    @Binding var objectToEdit: PassObject

    // Pass object created by this view.
    // This is @State because this view owns this PassObject
    // This PassObject will be swapped in for the @Binding passObject
    // when the save button is pressed
    // This is done so the user can made edits, which won't be saved until
    // the Save button is pressed
    @State private var tempObject: PassObject = .init()
    @State private var shouldShowSheet: Bool = false

    @State private var category: BarcodeCategory

    @State private var hasEditPassButtonBeenPressed = false
    @State private var textSize: CGSize = CGSizeZero

    @State private var isEditing: Bool = false
    @FocusState private var isTextFieldFocused: Bool

    @State private var showHelpPopover = false

    // On init, set the temp object owned by this view equal to the
    // one passed in via @Binding
    init(objectToEdit: Binding<PassObject>) {
        _objectToEdit = objectToEdit
        _tempObject = State(initialValue: objectToEdit.wrappedValue)
        _category = State(initialValue: objectToEdit.wrappedValue.barcodeType.toBarcodeCategory())
        initializeTempObject()
    }

    private func initializeTempObject() {
        tempObject.primaryFieldText == "" ? tempObject.primaryFieldText = "Default" : ()
    }

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            Form {
                Section {
                    Button(
                        action: {
                            hasEditPassButtonBeenPressed = true
                            objectToEdit = tempObject

                            // Delete existing pass's directory altogether, we will regenerate from scratch
                            let passDirectory = URL.documentsDirectory.appending(path: "\(objectToEdit.id.uuidString).pass")
                            let pkPassDirectory = URL.documentsDirectory.appending(path: "\(objectToEdit.id.uuidString).pkpass")
                            do {
                                try FileManager.default.removeItem(at: passDirectory)
                                try FileManager.default.removeItem(at: pkPassDirectory)
                            } catch {
                                print("Unable to delete pass dir")
                                modelData.passObjects.append(objectToEdit)
                            }

                            modelData.encodePassObjects()

                            if let pkpassDir = generatePass(passObject: objectToEdit) {
                                Task {
                                    passSigner.uploadPKPassFile(fileURL: pkpassDir, passUuid: objectToEdit.id)
                                }
                            }
                        }) {
                            ZStack {
                                ProgressView()
                                    .tint(.white)
                                    .opacity(hasEditPassButtonBeenPressed ? 1 : 0) // Fade-in effect
                                    .animation(.easeInOut(duration: 0.2), value: hasEditPassButtonBeenPressed)
                                    .offset(x: textSize.width / 2 + 20)
                                HStack {
                                    Spacer()
                                    Text("Save and Add to Wallet")
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.white)
                                        .readSize(into: $textSize)
                                    Spacer()
                                }
                            }
                        }
                        .disabled(hasEditPassButtonBeenPressed)
                        .opacity(hasEditPassButtonBeenPressed ? 0.4 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: hasEditPassButtonBeenPressed)
                }
                header: { // Slightly hacky way to get a custom view into a Form/List without having to adhere to the typical styling of the Form/List
                    EditablePassCard(passObject: $tempObject)
                        .textCase(nil) // Otherwise all text within the view will be all caps
                        .listRowInsets(.init(top: 40,
                                             leading: 0,
                                             bottom: 40,
                                             trailing: 0))
                        .listRowBackground(Color.clear)
                }
                .listRowBackground(Color.accentColor)

                Section {
                    Picker("Barcode Type", selection: $category) {
                        ForEach(BarcodeCategory.allCases, id: \.self) { type in
                            HStack {
                                Text(type.description)
                                if type == BarcodeCategory.none {
                                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                                } else if type == BarcodeCategory.twoDimensional {
                                    Image(systemName: "qrcode")
                                } else {
                                    Image(systemName: "barcode")
                                }
                            }.tag(type)
                        }
                    }
                    .onChange(of: category) {
                        switch category {
                        case BarcodeCategory.none:
                            tempObject.barcodeType = BarcodeType.none
                        case BarcodeCategory.oneDimensional:
                            tempObject.barcodeType = BarcodeType.code128
                        case BarcodeCategory.twoDimensional:
                            tempObject.barcodeType = BarcodeType.qr
                        }
                    }
                    .onChange(of: tempObject.barcodeType) { oldType, newType in
                        // Clear barcode string and strip image when a barcode that uses the strip image is selected
                        if oldType.doesBarcodeUseStripImage() && !newType.doesBarcodeUseStripImage() {
//                            tempObject.barcodeString = ""
                            tempObject.stripImage = Data()
                        }
                    }
                }

                ColorInput(pass: $tempObject)

                SecondaryFieldSelection(passObject: $tempObject)
                HeaderFieldSelection(passObject: $tempObject)
                if (tempObject.barcodeType == BarcodeType.none || tempObject.barcodeType == BarcodeType.code128 || tempObject.barcodeType == BarcodeType.pdf417 || tempObject.barcodeType == BarcodeType.qr) && tempObject.backgroundImage == Data() {
                    StripImageSelection(passObject: $tempObject)
                }
            }
            .listSectionSpacing(20)
        }
        .sheet(isPresented: $shouldShowSheet) {
            AddToWalletView(pass: getPkPass(fileURL: passSigner.fileURL!)) { wasAdded in
                if wasAdded {
                    print("Pass was successfully added to wallet")
                    presentationMode.wrappedValue.dismiss()
                } else {
                    print("Pass was not added to wallet")
                }

                hasEditPassButtonBeenPressed = false // Disable loading circle
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .onAppear {
            showHelpPopover = modelData.tutorialStage == 1
            passSigner.isDataLoaded = false
        }
        .onChange(of: passSigner.isDataLoaded) {
            if passSigner.isDataLoaded {
                shouldShowSheet = true
                hasEditPassButtonBeenPressed = false
                print(passSigner.isDataLoaded)
            }
        }
    }
}

#Preview {
    EditPass(objectToEdit: .constant(MockModelData().passObjects[0]))
}
