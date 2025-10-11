import SwiftUI

struct StripImageSelection: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var passObject: PassObject

    var body: some View {
        Toggle("Strip Image", isOn: $passObject.isCustomStripImageOn)
            .padding(14)
            .listSectionBackgroundModifier()
    }
}

#Preview {
    StripImageSelection(passObject: .constant(MockModelData().passObjects[0]))
}
