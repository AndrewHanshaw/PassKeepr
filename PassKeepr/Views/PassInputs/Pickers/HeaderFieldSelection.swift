import SwiftUI

struct HeaderFieldSelection: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var passObject: PassObject

    var body: some View {
        Toggle("Additional Header Field", isOn: $passObject.isHeaderFieldTwoOn)
            .padding(14)
            .listSectionBackgroundModifier()
    }
}

#Preview {
    HeaderFieldSelection(passObject: .constant(MockModelData().passObjects[0]))
}
