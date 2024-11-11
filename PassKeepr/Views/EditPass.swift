import SwiftUI

struct EditPass: View {
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
                        // When the save button is pressed, save the @Binding
                        // PassObject to the temp object with any user edits
                        action: {
                            objectToEdit = tempObject
                            presentationMode.wrappedValue.dismiss()
                        },
                        label: {
                            HStack {
                                Spacer()
                                Text("Save")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                Spacer()
                            }
                        }
                    )
                }
                .listRowBackground(Color.accentColor)
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
    }
}

#Preview {
    EditPass(objectToEdit: .constant(MockModelData().PassObjects[0]), isObjectEdited: .constant(false))
}
