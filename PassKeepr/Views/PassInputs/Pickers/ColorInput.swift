import SwiftUI

struct ColorInput: View {
    @Binding var pass: PassObject

    @State private var backgroundColor: Color = .black
    @State private var foregroundColor: Color = .black
    @State private var labelColor: Color = .black

    var body: some View {
        Section {
            if pass.backgroundImage == Data() {
                ColorPicker("Background Color", selection: $backgroundColor)
                    .onChange(of: backgroundColor) {
                        pass.backgroundColor = backgroundColor.toHex()
                    }
                ColorPicker("Text Color", selection: $foregroundColor)
                    .onChange(of: foregroundColor) {
                        pass.foregroundColor = foregroundColor.toHex()
                    }
            }
            ColorPicker("Label Color", selection: $labelColor)
        }
        .onAppear {
            backgroundColor = Color(hex: pass.backgroundColor)
            foregroundColor = Color(hex: pass.foregroundColor)
            labelColor = Color(hex: pass.labelColor)
        }
    }
}

#Preview {
    ColorInput(pass: .constant(ModelData().passObjects[0]))
}
