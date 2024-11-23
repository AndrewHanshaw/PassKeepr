import SwiftUI

struct EditPass: View {
    @EnvironmentObject var passSigner: pkPassSigner

    // Pass object passed into this view.
    // We want to update this object when the save button is pressed
    @Binding var objectToEdit: PassObject

    // Boolean used by the parent view to determine whether the item was edited
    @Binding var isObjectEdited: Bool

    // Pass object created by this view.
    // This is @State because this view owns this PassObject
    // This PassObject will be swapped in for the @Binding passObject
    // when the save button is pressed
    // This is done so the user can made edits, which won't be saved until
    // the Save button is pressed
    @State private var tempObject: PassObject = .init()

    @State private var hasEditPassButtonBeenPressed = false
    @State private var textWidth: CGFloat = 0

    // On init, set the temp object owned by this view equal to the
    // one passed in via @Binding
    init(objectToEdit: Binding<PassObject>, isObjectEdited: Binding<Bool>) {
        _objectToEdit = objectToEdit
        _isObjectEdited = isObjectEdited
        _tempObject = State(initialValue: objectToEdit.wrappedValue)
        initializeTempObject()
    }

    private func initializeTempObject() {
        tempObject.passName == "" ? tempObject.passName = "Default Name" : ()
    }

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            Form {
                PassInput(pass: $tempObject)

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
                            }

                            if let pkpassDir = generatePass(passObject: objectToEdit) {
                                Task {
                                    passSigner.uploadPKPassFile(fileURL: pkpassDir, passUuid: objectToEdit.id)
                                }
                            }
                        }) {
                            ZStack {
                                ProgressView()
                                    .tint(.white)
                                    .opacity(hasEditPassButtonBeenPressed && !passSigner.isDataLoaded ? 1 : 0) // Fade-in effect
                                    .animation(.easeInOut(duration: 0.2), value: hasEditPassButtonBeenPressed && !passSigner.isDataLoaded)
                                    .offset(x: textWidth / 2 + 20)
                                Text("Save")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .readWidth(into: $textWidth)
                            }
                        }
                        .disabled(hasEditPassButtonBeenPressed)
                        .opacity(hasEditPassButtonBeenPressed ? 0.4 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: hasEditPassButtonBeenPressed)
                }
                .listRowBackground(Color.accentColor)

                OptionalPassConfiguration(passObject: $tempObject)
            }
        }
        .navigationTitle($tempObject.passName)
        .onChange(of: tempObject) {
            if tempObject != objectToEdit {
                isObjectEdited = true
            } else {
                isObjectEdited = false
            }
        }
        .onDisappear {
            // This will be triggered when the back button is pressed
            isObjectEdited = false // Reset the flag because the user did not save changes
        }
        .sheet(isPresented: $passSigner.isDataLoaded) {
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
    }
}

#Preview {
    EditPass(objectToEdit: .constant(MockModelData().passObjects[0]), isObjectEdited: .constant(false))
}
