import PassKit
import SwiftUI

struct EditPass: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var passSigner: pkPassSigner
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    // Pass object passed into this view.
    // We want to update this object when the save button is pressed
    @Binding var objectToEdit: PassObject

    // Pass object created by this view.
    // This is @State because this view owns this PassObject
    // Changes are committed to objectToEdit (and modelData) automatically via auto-save.
    @State private var tempObject: PassObject = .init()
    @State private var shouldShowSheet: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    let isNewPass: Bool
    let shouldProvideOwnNavigation: Bool

    @State private var hasEditPassButtonBeenPressed = false
    @State private var textSize: CGSize = CGSizeZero

    @FocusState private var isTextFieldFocused: Bool

    @State private var isWalletSupported = false
    /// Tracks the pass group at the time of last successful sign, to detect group changes for Wallet cleanup.
    @State private var previouslySignedGroup: Int = -1
    @State private var isCustomizeLogoImagePresented = false
    @State private var isCustomizeBackgroundImagePresented = false
    @State private var isCustomizeStripImagePresented = false
    @State private var isCustomizeThumbnailImagePresented = false
    @State private var isCustomizeBarcodePresented = false
    @State private var isCustomizeQrCodePresented = false

    // On init, set the temp object owned by this view equal to the
    // one passed in via @Binding
    init(objectToEdit: Binding<PassObject>, isNewPass: Bool, shouldProvideOwnNavigation: Bool = true) {
        _objectToEdit = objectToEdit
        self.isNewPass = isNewPass
        self.shouldProvideOwnNavigation = shouldProvideOwnNavigation
        _tempObject = State(initialValue: objectToEdit.wrappedValue)
    }

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        if shouldProvideOwnNavigation {
            NavigationStack { content }
        } else {
            content
        }
    }

    // On iPhone, verticalSizeClass reflects interface orientation and is available
    // synchronously from the first render, unlike onGeometryChange-based measurement
    // (which starts with a wrong guess and corrects a frame later, causing the pass
    // card's own size-dependent layout to sometimes latch onto the wrong initial width).
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }

    @ViewBuilder
    private var content: some View {
        Group {
            if isLandscape {
                landscapeLayout
            } else {
                portraitLayout
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(isNewPass && tempObject.description == PassObject.defaultDescription ? .init(get: { "New Pass" }, set: { tempObject.description = $0 }) : $tempObject.description)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    let result = prepareForSigning()
                    if !result.success {
                        hasEditPassButtonBeenPressed = false
                        showAlert = true
                        alertMessage = result.errorMessage ?? ""
                    } else if let pkpassDir = generatePass(passObject: tempObject) {
                        Task {
                            passSigner.uploadPKPassFile(fileURL: pkpassDir, passUuid: tempObject.id)
                        }
                    } else {
                        hasEditPassButtonBeenPressed = false
                        showAlert = true
                        alertMessage = "Failed to generate pass file"
                    }
                }) {
                    Label("Sign Pass", image: ImageResource(name: "custom.wallet.pass.badge.plus", bundle: .main))
                }
                .toolbarConfirmButtonModifier()
            }

            if shouldProvideOwnNavigation {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .toolbarCancelButtonModifier()
                }
            }
        }
        .background(colorScheme == .light ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
        .sheet(isPresented: $isCustomizeLogoImagePresented) {
            CustomizeLogoImage(passObject: $tempObject)
                .edgesIgnoringSafeArea(.bottom)
        }
        .sheet(isPresented: $isCustomizeBackgroundImagePresented) {
            CustomizeBackgroundImage(passObject: $tempObject)
                .edgesIgnoringSafeArea(.bottom)
        }
        .sheet(isPresented: $isCustomizeThumbnailImagePresented) {
            CustomizeThumbnailImage(passObject: $tempObject)
                .edgesIgnoringSafeArea(.bottom)
        }
        .sheet(isPresented: $isCustomizeStripImagePresented) {
            CustomizeStripImage(passObject: $tempObject)
                .edgesIgnoringSafeArea(.bottom)
        }
        .sheet(isPresented: $isCustomizeBarcodePresented) {
            CustomizeBarcode(passObject: $tempObject)
                .edgesIgnoringSafeArea(.bottom)
        }
        .sheet(isPresented: $isCustomizeQrCodePresented) {
            CustomizeQrCode(passObject: $tempObject)
                .edgesIgnoringSafeArea(.bottom)
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
                let appSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                let destinationURL = appSupportDirectory.appendingPathComponent("\(tempObject.id).pkpass")

                ActivityView(activityItems: [destinationURL]) {
                    presentationMode.wrappedValue.dismiss()
                    hasEditPassButtonBeenPressed = false // Disable loading circle
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .onAppear {
            passSigner.isDataLoaded = false
            isWalletSupported = PKAddPassesViewController.canAddPasses()
            previouslySignedGroup = objectToEdit.group
        }
        .onChange(of: objectToEdit) { _, newValue in
            // Update tempObject when the binding changes (e.g., from import)
            if tempObject.id != newValue.id {
                tempObject = newValue
            }
        }
        .onChange(of: tempObject) { _, newValue in
            objectToEdit = newValue
            if isNewPass && !modelData.passObjects.contains(where: { $0.id == newValue.id }) {
                modelData.passObjects.append(newValue)
            }
            modelData.encodePassObjects()
        }
        .onChange(of: passSigner.isDataLoaded) {
            if passSigner.isDataLoaded {
                shouldShowSheet = true
                previouslySignedGroup = tempObject.group
                hasEditPassButtonBeenPressed = false
                print("hasEditPassButtonBeenPressed = false")
                print(passSigner.isDataLoaded)
            }
        }
        .onChange(of: passSigner.uploadErrorMessage) {
            if let message = passSigner.uploadErrorMessage {
                alertMessage = message
                showAlert = true
                hasEditPassButtonBeenPressed = false
                passSigner.uploadErrorMessage = nil
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Failed to Update Pass"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
        }
    }

    @ViewBuilder
    private var portraitLayout: some View {
        ScrollView {
            ScrollViewReader { proxy in
                VStack(spacing: 20) {
                    passCardView
                    formFields(proxy: proxy)
                }
                .padding()
            }
        }
    }

    @ViewBuilder
    private var landscapeLayout: some View {
        HStack(spacing: 0) {
            ScrollView {
                passCardView
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)

            Divider()

            ScrollView {
                ScrollViewReader { proxy in
                    formFields(proxy: proxy)
                        .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var passCardView: some View {
        EditablePassCard(
            passObject: $tempObject,
            isSigningPass: hasEditPassButtonBeenPressed,
            isCustomizeLogoImagePresented: $isCustomizeLogoImagePresented,
            isCustomizeBackgroundImagePresented: $isCustomizeBackgroundImagePresented,
            isCustomizeStripImagePresented: $isCustomizeStripImagePresented,
            isCustomizeThumbnailImagePresented: $isCustomizeThumbnailImagePresented,
            isCustomizeBarcodePresented: $isCustomizeBarcodePresented,
            isCustomizeQrCodePresented: $isCustomizeQrCodePresented
        )
        .padding([.leading, .trailing], 6)
    }

    @ViewBuilder
    private func formFields(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 20) {
            BarcodeTypePicker(pass: $tempObject, disableControl: hasEditPassButtonBeenPressed)

            ColorInput(pass: $tempObject, disableControl: hasEditPassButtonBeenPressed)

            SecondaryFieldSelection(passObject: $tempObject, disableControl: hasEditPassButtonBeenPressed)
            AuxiliaryFieldSelection(passObject: $tempObject, disableControl: hasEditPassButtonBeenPressed)
            HeaderFieldSelection(passObject: $tempObject, disableControl: hasEditPassButtonBeenPressed)

            if (tempObject.barcodeType == BarcodeType.none || tempObject.barcodeType == BarcodeType.code128 || tempObject.barcodeType == BarcodeType.pdf417 || tempObject.barcodeType == BarcodeType.qr) && tempObject.backgroundImage == Data() {
                StripImageSelection(passObject: $tempObject, disableControl: hasEditPassButtonBeenPressed)
            }

            PassGroupPicker(pass: $tempObject, disableControl: hasEditPassButtonBeenPressed)

            ExpirationDatePicker(pass: $tempObject, disableControl: hasEditPassButtonBeenPressed)
                .id("expirationDatePicker")

            LocationSelection(passObject: $tempObject, disableControl: hasEditPassButtonBeenPressed)
                .id("locationSelection")
        }
        .onChange(of: tempObject.hasExpirationDate) { _, isEnabled in
            guard isEnabled else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation { proxy.scrollTo("expirationDatePicker", anchor: .bottom) }
            }
        }
        .onChange(of: tempObject.locations.count) { oldCount, newCount in
            guard newCount > oldCount else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation { proxy.scrollTo("locationSelection", anchor: .bottom) }
            }
        }
    }

    private func prepareForSigning() -> (success: Bool, errorMessage: String?) {
        hasEditPassButtonBeenPressed = true

        // If the group changed since the last sign, remove the stale Wallet pass
        let newGroup = tempObject.group
        if previouslySignedGroup != -1 && newGroup != previouslySignedGroup {
            let passLibrary = PKPassLibrary()
            if PKPassLibrary.isPassLibraryAvailable() {
                let oldPassTypeIdentifier = "pass.com.hanshaw.passKeepr.\(previouslySignedGroup)"
                let serialNumber = tempObject.id.uuidString
                if let oldPass = passLibrary.pass(withPassTypeIdentifier: oldPassTypeIdentifier, serialNumber: serialNumber) {
                    passLibrary.removePass(oldPass)
                }
            }
        }

        do {
            // Delete existing pass files so we can regenerate from scratch.
            // This must happen regardless of isNewPass — if the user declines the wallet
            // prompt and tries again, the .pkpass from the previous attempt still exists.
            let passDirectory = URL.applicationSupportDirectory.appending(path: "\(tempObject.id.uuidString).pass")
            let pkPassDirectory = URL.applicationSupportDirectory.appending(path: "\(tempObject.id.uuidString).pkpass")

            if FileManager.default.fileExists(atPath: passDirectory.path) {
                try FileManager.default.removeItem(at: passDirectory)
            }
            if FileManager.default.fileExists(atPath: pkPassDirectory.path) {
                try FileManager.default.removeItem(at: pkPassDirectory)
            }
        } catch {
            return (false, "Deleting existing pass data was unsuccessful: \(error.localizedDescription)")
        }

        return (true, nil)
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
