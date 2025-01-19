import SwiftUI

struct ColorInput: View {
    @Binding var pass: PassObject

    var body: some View {
        Section {
            ColorPicker("Background Color", selection: Color.binding(from: $pass.backgroundColor))
            ColorPicker("Foreground Color", selection: Color.binding(from: $pass.foregroundColor))
            ColorPicker("Label Color", selection: Color.binding(from: $pass.labelColor))
        }
    }
}

#Preview {
    ColorInput(pass: .constant(ModelData().passObjects[0]))
}
