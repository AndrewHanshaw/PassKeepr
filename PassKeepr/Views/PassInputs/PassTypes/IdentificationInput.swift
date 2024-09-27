import SwiftUI

struct IdentificationInput: View {
    @Binding var identificationInput: String

    var body: some View {
        Section {
            LabeledContent {
                TextField("ID", text: $identificationInput)
            } label: {
                Text("ID Text")
            }
        }
    }
}

#Preview {
    IdentificationInput(identificationInput: .constant("T35T-1D3NT1F1C4T10N"))
}
