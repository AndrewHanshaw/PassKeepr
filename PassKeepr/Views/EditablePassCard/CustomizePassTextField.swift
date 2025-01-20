import SwiftUI

struct CustomizePassTextField: View {
    @Binding var textLabel: String
    @Binding var text: String

    var body: some View {
        VStack {
            TextField("Label", text: $textLabel)
                .disableAutocorrection(true)
                .textCase(.uppercase)
            TextField("Text", text: $text)
                .disableAutocorrection(true)
        }
        .padding(5)
    }
}

#Preview {
    CustomizePassTextField(textLabel: .constant("Header"), text: .constant("Text"))
}
