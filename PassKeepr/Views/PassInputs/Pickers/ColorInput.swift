import SwiftUI

struct ColorInput: View {
    @Binding var pass: PassObject

    var body: some View {
        VStack {
            ColorPicker("Background Color", selection: Color.binding(from: $pass.backgroundColor))
            ColorPicker("Foreground Color", selection: Color.binding(from: $pass.foregroundColor))
            ColorPicker("Text Color", selection: Color.binding(from: $pass.textColor))
        }
    }
}

#Preview {
    ColorInput(pass: .constant(ModelData().PassObjects[0]))
}
