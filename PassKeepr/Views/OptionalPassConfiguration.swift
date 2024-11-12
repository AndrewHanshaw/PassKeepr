import SwiftUI

struct OptionalPassConfiguration: View {
    @Binding var passObject: PassObject

    @State private var enableHeaderField = false
    @State private var headerFieldLabel = ""
    @State private var headerFieldText = ""

    var body: some View {
        Section {
            HStack {
                Spacer()
                Text("Optional Customizations:")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .listSectionSpacing(0)
        .listRowBackground(Color.clear)

        ColorInput(pass: $passObject)

        LogoImagePicker(passObject: $passObject)

        AdditionalFieldInput(enableHeaderField: $enableHeaderField, labelInput: $headerFieldLabel, textInput: $headerFieldText)
    }
}

#Preview {
    OptionalPassConfiguration(passObject: .constant(MockModelData().PassObjects[0]))
}
