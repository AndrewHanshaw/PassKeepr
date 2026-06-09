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
        .onChange(of: pass.backgroundColor) {
            // Keep text legible: if a text/label colour no longer has enough contrast against the
            // new background, flip it to black or white. Colours that are still legible are left as-is.
            let minContrast = 4.5 // WCAG AA for normal text
            if Color.contrastRatio(pass.foregroundColor, pass.backgroundColor) < minContrast {
                pass.foregroundColor = Color.legibleTextColor(onBackground: pass.backgroundColor)
            }
            if Color.contrastRatio(pass.labelColor, pass.backgroundColor) < minContrast {
                pass.labelColor = Color.legibleTextColor(onBackground: pass.backgroundColor)
            }
        }
    }
}

#Preview {
    ColorInput(pass: .constant(MockModelData().passObjects[0]), disableControl: false)
}
