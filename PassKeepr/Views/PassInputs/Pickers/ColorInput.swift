import SwiftUI

struct ColorInput: View {
    @Binding var pass: PassObject

    var disableControl: Bool

    var body: some View {
        VStack(spacing: 12) {
            if pass.backgroundImage == Data() {
                ColorPicker("Background Color", selection: Color.binding(from: $pass.backgroundColor), supportsOpacity: false)
                    .padding([.top, .bottom], 16)
                    .overlay(Divider(), alignment: .bottom)
                    .padding([.leading, .trailing], 16)
                    .disabled(disableControl)

                // Text color is forced to white when there is a background image
                ColorPicker("Text Color", selection: Color.binding(from: $pass.foregroundColor), supportsOpacity: false)
                    .padding([.bottom], 16)
                    .overlay(Divider(), alignment: .bottom)
                    .padding([.leading, .trailing], 16)
                    .disabled(disableControl)
            }
            ColorPicker("Label Color", selection: Color.binding(from: $pass.labelColor), supportsOpacity: false)
                .padding([.leading, .trailing, .bottom], 16)
                .padding(.top, pass.backgroundImage == Data() ? 0 : 16) // Need to add top padding only when the other two pickers are not shown
                .disabled(disableControl)
        }
        .listSectionBackgroundModifier()
    }
}

#Preview {
    ColorInput(pass: .constant(MockModelData().passObjects[0]), disableControl: false)
}
