import SwiftUI

struct StripImageSelection: View {
    @Binding var passObject: PassObject

    var body: some View {
        Section {
            Toggle(isOn: $passObject.isCustomStripImageOn) {
                Text("Strip Image")
            }
        }
    }
}

#Preview {
    StripImageSelection(passObject: .constant(MockModelData().passObjects[0]))
}
