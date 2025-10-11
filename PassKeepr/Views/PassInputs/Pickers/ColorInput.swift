import SwiftUI

struct ColorInput: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var pass: PassObject

    @State private var backgroundColor: Color = .black
    @State private var foregroundColor: Color = .black
    @State private var labelColor: Color = .black

    var body: some View {
        VStack(spacing: 12) {
            if pass.backgroundImage == Data() {
                ColorPicker("Background Color", selection: $backgroundColor)
                    .onChange(of: backgroundColor) {
                        pass.backgroundColor = backgroundColor.toHex()
                    }
                    .padding([.top, .bottom], 16)
                    .overlay(Divider(), alignment: .bottom)
                    .padding([.leading, .trailing], 16)

                // Text color is forced to white when there is a background image
                ColorPicker("Text Color", selection: $foregroundColor)
                    .onChange(of: foregroundColor) {
                        pass.foregroundColor = foregroundColor.toHex()
                    }
                    .padding([.bottom], 16)
                    .overlay(Divider(), alignment: .bottom)
                    .padding([.leading, .trailing], 16)
                    .background(colorScheme == .light ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
            }
            ColorPicker("Label Color", selection: $labelColor)
                .onChange(of: labelColor) {
                    pass.labelColor = labelColor.toHex()
                }
                .padding([.leading, .trailing, .bottom], 16)
                .padding(.top, pass.backgroundImage == Data() ? 0 : 16) // Need to add top padding only when the other two pickers are disabled
                .background(colorScheme == .light ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
        }
        .listSectionBackgroundModifier()
        .onAppear {
            backgroundColor = Color(hex: pass.backgroundColor)
            foregroundColor = Color(hex: pass.foregroundColor)
            labelColor = Color(hex: pass.labelColor)
        }
    }
}

#Preview {
    ColorInput(pass: .constant(MockModelData().passObjects[0]))
}
