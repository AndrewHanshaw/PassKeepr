import SwiftUI

struct AuxiliaryTextField: View {
    var backgroundBrightness: BackgroundBrightness
    var disableButton: Bool

    @Binding var textLabel: String
    @Binding var text: String

    var textColor: Color
    var labelColor: Color

    @State private var isCustomizeTextPresented = false

    var body: some View {
        Group {
            if textLabel != "" || text != "" {
                VStack(alignment: .leading, spacing: 0) {
                    Text(textLabel)
                        .lineLimit(1)
                        .frame(alignment: .top)
                        .foregroundColor(labelColor)
                        .disableAutocorrection(true)
                        .textCase(.uppercase)
                        .font(.system(size: 11))
                        .fontWeight(.semibold)
                        .padding(0)
                        .padding(.top, -2)

                    Text(text)
                        .lineLimit(1)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .foregroundColor(textColor)
                        .disableAutocorrection(true)
                        .font(.system(size: 26))
                        .fontWeight(.light)
                        .padding(0)
                        .minimumScaleFactor(0.34)
                }
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                        .foregroundColor(backgroundBrightness.overwriteForegroundColor)
                        .opacity(backgroundBrightness.overwriteOpacityRoundedRectangle)
                        .aspectRatio(2, contentMode: .fit)
                    Text("Auxiliary\nField")
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.34)
                        .foregroundColor(backgroundBrightness.overwriteForegroundColor)
                        .opacity(backgroundBrightness.overwriteOpacity)
                        .padding(2)
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                isCustomizeTextPresented.toggle()
            }) {
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.green, .white)
                    .font(.system(size: 18))
                    .shadow(radius: 3, x: 0, y: 0)
            }
            .offset(x: 9, y: 9)
            .buttonStyle(PlainButtonStyle())
            .disabled(disableButton)
        }
        .popover(isPresented: $isCustomizeTextPresented, arrowEdge: .top) {
            CustomizePassTextField(textLabel: $textLabel, text: $text)
                .presentationCompactAdaptation((.popover))
        }
    }
}

#Preview {
    AuxiliaryTextField(backgroundBrightness: .normal, disableButton: false, textLabel: .constant("HEADER"), text: .constant("TEST"), textColor: .black, labelColor: .black)
}
