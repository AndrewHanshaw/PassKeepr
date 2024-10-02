import SwiftUI

struct IdentificationInput: View {
    @Binding var passObject: PassObject

    var body: some View {
        Section {
            LabeledContent {
                TextField("ID", text: $passObject.identificationString)
            } label: {
                Text("ID Text")
            }
        }
    }
}

#Preview {
    IdentificationInput(passObject: .constant(MockModelData().PassObjects[0]))
}
