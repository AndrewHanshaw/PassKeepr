import SwiftUI

struct ColorInput: View {
    @Binding var pass: PassObject

    var body: some View {
        VStack {
            ColorPicker("Background Color", selection: Color.binding(from: $pass.backgroundColor))
                .padding(.top, 5)
            ColorPicker("Foreground Color", selection: Color.binding(from: $pass.foregroundColor))
                .padding([.top, .bottom], 10)
            ColorPicker("Text Color", selection: Color.binding(from: $pass.textColor))
                .padding(.bottom, 5)
        }
    }
}

#Preview {
    ColorInput(pass: .constant(ModelData().PassObjects[0]))
}
