import SwiftUI

struct ColorInput: View {
    @Binding var pass: PassObject

    var body: some View {
        Section {
            ColorPicker("Background Color", selection: Color.binding(from: $pass.backgroundColor))
        }

        if getIsBackgroundImageSupported(passObject: pass) {
            Section {
                HStack {
                    Spacer()
                    Text("Or:")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .listSectionSpacing(0)
            .listRowBackground(Color.clear)

            Section {
                BackgroundImagePicker(passObject: $pass)
            }
        }

        Section {
            ColorPicker("Foreground Color", selection: Color.binding(from: $pass.foregroundColor))
            ColorPicker("Label Color", selection: Color.binding(from: $pass.labelColor))
        }
    }
}

#Preview {
    ColorInput(pass: .constant(ModelData().PassObjects[0]))
}
