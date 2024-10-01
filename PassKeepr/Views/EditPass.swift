import SwiftUI

struct EditPass: View {
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

    // On init, set the temp object owned by this view equal to the
    // one passed in via @Binding
    init(objectToEdit: Binding<PassObject>) {
        _objectToEdit = objectToEdit
        _tempObject = State(initialValue: objectToEdit.wrappedValue)
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
    }
}

#Preview {
    EditPass(objectToEdit: .constant(MockModelData().PassObjects[0]))
}
