import SwiftUI

struct StripImageSelection: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var passObject: PassObject

    var disableControl: Bool

    var body: some View {
        Toggle("Strip Image", isOn: $passObject.isCustomStripImageOn)
            .padding(14)
            .listSectionBackgroundModifier()
            .disabled(disableControl)
    }
}

#Preview {
    StripImageSelection(passObject: .constant(MockModelData().passObjects[0]), disableControl: false)
}
