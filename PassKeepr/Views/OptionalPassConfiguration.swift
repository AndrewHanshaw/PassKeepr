import SwiftUI

struct OptionalPassConfiguration: View {
    @Binding var passObject: PassObject

    @State private var enableHeaderField = false
    @State private var headerFieldLabel = ""
    @State private var headerFieldText = ""

    var body: some View {
        Section {
            Text("Optional Customizations:")
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.system(size: 20))
                .foregroundColor(.secondary)
        }
        .listSectionSpacing(0)
        .listRowBackground(Color.clear)

        LogoImagePicker(passObject: $passObject)

        AdditionalFieldInput(enableHeaderField: $enableHeaderField, labelInput: $headerFieldLabel, textInput: $headerFieldText)
    }
}

#Preview {
    OptionalPassConfiguration(passObject: .constant(MockModelData().passObjects[0]))
}
