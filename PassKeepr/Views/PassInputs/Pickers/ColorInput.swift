import SwiftUI

struct ColorInput: View {
    @Binding var pass: PassObject

    var body: some View {
        Section {
            if pass.backgroundImage == Data() {
                ColorPicker("Background Color", selection: Color.binding(from: $pass.backgroundColor))
            }
            ColorPicker("Text Color", selection: Color.binding(from: $pass.foregroundColor))
            ColorPicker("Label Color", selection: Color.binding(from: $pass.labelColor))
        }
    }
}

#Preview {
    ColorInput(pass: .constant(ModelData().passObjects[0]))
}
