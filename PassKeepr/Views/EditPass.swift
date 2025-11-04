import PassKit
import SwiftUI

struct EditPass: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var passSigner: pkPassSigner
    @Environment(\.colorScheme) var colorScheme

    // Pass object passed into this view.
    // We want to update this object when the save button is pressed
    @Binding var objectToEdit: PassObject

    // Pass object created by this view.
    // This is @State because this view owns this PassObject
    // This PassObject will be swapped in for the @Binding passObject
    // when the save button is pressed
    // This is done so the user can make edits, which won't be saved until
    // the Save button is pressed
    @State private var tempObject: PassObject = .init()
    @State private var shouldShowSheet: Bool = false
    @State private var showAlert: Bool = false

    let isNewPass: Bool

    @State private var hasEditPassButtonBeenPressed = false
    @State private var textSize: CGSize = CGSizeZero

    @FocusState private var isTextFieldFocused: Bool

    @State private var showHelpPopover = false
    @State private var isWalletSupported = false

    // On init, set the temp object owned by this view equal to the
    // one passed in via @Binding
    init(objectToEdit: Binding<PassObject>, isNewPass: Bool) {
        _objectToEdit = objectToEdit
        self.isNewPass = isNewPass
        _tempObject = State(initialValue: objectToEdit.wrappedValue)
        initializeTempObject()
    }

    private func initializeTempObject() {
        tempObject.primaryFieldText == "" ? tempObject.primaryFieldText = "Default" : ()
    }

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    EditablePassCard(passObject: $tempObject, isSigningPass: hasEditPassButtonBeenPressed)
                        .padding([.leading, .trailing], 6)
                        .padding(.top, 56)

                    BarcodeTypePicker(pass: $tempObject, disableControl: hasEditPassButtonBeenPressed)

                    ColorInput(pass: $tempObject, disableControl: hasEditPassButtonBeenPressed)

                    SecondaryFieldSelection(passObject: $tempObject, disableControl: hasEditPassButtonBeenPressed)
                    HeaderFieldSelection(passObject: $tempObject, disableControl: hasEditPassButtonBeenPressed)

                    if (tempObject.barcodeType == BarcodeType.none || tempObject.barcodeType == BarcodeType.code128 || tempObject.barcodeType == BarcodeType.pdf417 || tempObject.barcodeType == BarcodeType.qr) && tempObject.backgroundImage == Data() {
                        StripImageSelection(passObject: $tempObject, disableControl: hasEditPassButtonBeenPressed)
                    }
                }
                .padding()
            }
            .ignoresSafeArea(edges: .top)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(isNewPass ? "New Pass" : "Edit Pass")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }

                ToolbarItem(placement: .confirmationAction) {
                    // This weird initializer for Menu is the only way I could find to get it to apply the GlassProminentButtonStyle on iOS 26
                    Menu("Done", systemImage: "checkmark", content: {
                        Button("Save + Add to Wallet", image: ImageResource(name: "custom.wallet.pass.badge.plus", bundle: .main), action: { showAlert = !saveWithoutAddingToWallet()
                            if let pkpassDir = generatePass(passObject: objectToEdit) {
                                Task {
                                    passSigner.uploadPKPassFile(fileURL: pkpassDir, passUuid: objectToEdit.id)
                                }
                            }
                        })
                        .labelStyle(.titleAndIcon) // default on iOS 26, needed for older versions

                        Button("Save without Adding", systemImage: "square.and.arrow.down") {
                            if saveWithoutAddingToWallet() {
                                _ = generatePass(passObject: objectToEdit)
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                showAlert = true
                            }
                        }
                        .labelStyle(.titleAndIcon) // default on iOS 26, needed for older versions
                    })
                    .toolbarConfirmButtonModifier()
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .toolbarCancelButtonModifier()
                }
            }
            .background(colorScheme == .light ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
        }
        .sheet(isPresented: $shouldShowSheet) {
            if isWalletSupported {
                AddToWalletView(pass: getPkPass(fileURL: passSigner.fileURL!)) { wasAdded in
                    if wasAdded {
                        print("Pass was successfully added to wallet")
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        print("Pass was not added to wallet")
                    }

                    hasEditPassButtonBeenPressed = false // Disable loading circle
                }
            } else {
                let fileManager = FileManager.default
                let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destinationURL = documentsDirectory.appendingPathComponent("\(tempObject.id).pkpass")

                ActivityView(activityItems: [destinationURL]) {
                    presentationMode.wrappedValue.dismiss()
                    hasEditPassButtonBeenPressed = false // Disable loading circle
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .onAppear {
            showHelpPopover = modelData.tutorialStage == 1
            passSigner.isDataLoaded = false
            isWalletSupported = PKAddPassesViewController.canAddPasses()
        }
        .onChange(of: passSigner.isDataLoaded) {
            if passSigner.isDataLoaded {
                shouldShowSheet = true
                hasEditPassButtonBeenPressed = false
                print("hasEditPassButtonBeenPressed = false")
                print(passSigner.isDataLoaded)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Failed to Update Pass"),
                  message: Text("Deleting existing pass data was unsuccessful."),
                  dismissButton: .default(Text("OK")))
        }
    }

    func saveWithoutAddingToWallet() -> Bool {
        hasEditPassButtonBeenPressed = true
        objectToEdit = tempObject

        if !isNewPass {
            do {
                // Delete existing pass's directory altogether, we will regenerate from scratch
                let passDirectory = URL.documentsDirectory.appending(path: "\(objectToEdit.id.uuidString).pass")
                let pkPassDirectory = URL.documentsDirectory.appending(path: "\(objectToEdit.id.uuidString).pkpass")

                try FileManager.default.removeItem(at: passDirectory)
                try FileManager.default.removeItem(at: pkPassDirectory)
            } catch {
                return false
            }
        } else {
            modelData.passObjects.append(objectToEdit)
        }

        modelData.encodePassObjects()
        return true
    }

    struct ActivityView: UIViewControllerRepresentable {
        let activityItems: [Any]
        let applicationActivities: [UIActivity]? = nil
        var completion: (() -> Void)? // Completion handler to notify dismissal

        func makeUIViewController(context _: Context) -> UIActivityViewController {
            let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
            controller.completionWithItemsHandler = { _, _, _, _ in
                completion?() // Call the completion handler when the share sheet is dismissed
            }
            return controller
        }

        func updateUIViewController(_: UIActivityViewController, context _: Context) {
            // No updates needed
        }
    }
}

#Preview {
    EditPass(objectToEdit: .constant(MockModelData().passObjects[0]), isNewPass: true)
}
