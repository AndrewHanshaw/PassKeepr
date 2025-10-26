import SwiftUI

struct HeaderFieldSelection: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var passObject: PassObject

    var disableControl: Bool

    var body: some View {
        Toggle("Additional Header Field", isOn: $passObject.isHeaderFieldTwoOn)
            .padding(14)
            .listSectionBackgroundModifier()
            .disabled(disableControl)
    }
}

#Preview {
    HeaderFieldSelection(passObject: .constant(MockModelData().passObjects[0]), disableControl: false)
}
