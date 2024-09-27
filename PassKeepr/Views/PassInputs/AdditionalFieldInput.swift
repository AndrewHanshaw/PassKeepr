import SwiftUI

struct AdditionalFieldInput: View {
    @Binding var enableHeaderField: Bool
    @Binding var labelInput: String
    @Binding var textInput: String

    var body: some View {
        Section {
            Toggle(isOn: $enableHeaderField) {
                Text("Additional Header field")
            }

            if enableHeaderField == true {
                LabeledContent {
                    TextField("Text", text: $textInput)
                } label: {
                    Text("Text")
                }

                LabeledContent {
                    TextField("Optional", text: $labelInput)
                } label: {
                    Text("Label")
                }
            }
        }
    }
}

#Preview {
    AdditionalFieldInput(enableHeaderField: .constant(false), labelInput: .constant(""), textInput: .constant(""))
}
