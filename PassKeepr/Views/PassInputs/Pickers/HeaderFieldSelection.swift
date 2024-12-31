import SwiftUI

struct HeaderFieldSelection: View {
    @Binding var passObject: PassObject

    var body: some View {
        Section {
            Toggle(isOn: $passObject.isHeaderFieldTwoOn) {
                Text("Additional Header Field")
            }
        }
    }
}

#Preview {
    HeaderFieldSelection(passObject: .constant(ModelData().passObjects[0]))
}
