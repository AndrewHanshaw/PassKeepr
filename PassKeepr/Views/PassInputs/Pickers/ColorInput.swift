import SwiftUI

struct ColorInput: View {
    @Binding var pass: PassObject

    var body: some View {
        Section {
            ColorPicker("Background Color", selection: Color.binding(from: $pass.backgroundColor))
        } footer: {
            HStack {
                Spacer()
                Text("Or:")
                    .font(.system(size: 20))
                Spacer()
            }
            .padding(.bottom, -.infinity)
            .padding(.top, 10)
        }

        Section {
            BackgroundImagePicker(passObject: $pass)
        }
        Section {
            ColorPicker("Foreground Color", selection: Color.binding(from: $pass.foregroundColor))
            ColorPicker("Text Color", selection: Color.binding(from: $pass.textColor))
        }
    }
}

#Preview {
    ColorInput(pass: .constant(ModelData().PassObjects[0]))
}
