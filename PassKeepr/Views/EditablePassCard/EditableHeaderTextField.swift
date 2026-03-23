import SwiftUI

struct EditableHeaderTextField: View {
    var backgroundBrightness: BackgroundBrightness
    var disableButton: Bool

    @Binding var textLabel: String
    @Binding var text: String

    var textColor: Color
    var labelColor: Color

    @State private var isCustomizeTextPresented = false

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            if textLabel != "" || text != "" {
                Text(textLabel)
                    .lineLimit(1)
                    .frame(alignment: .topTrailing)
                    .foregroundColor(labelColor)
                    .disableAutocorrection(true)
                    .textCase(.uppercase)
                    .font(.system(size: 11))
                    .fontWeight(.semibold)
                    .padding(0)

                Text(text)
                    .lineLimit(1)
                    .frame(maxHeight: .infinity, alignment: .topTrailing)
                    .foregroundColor(textColor)
                    .disableAutocorrection(true)
                    .padding(0)
                    .minimumScaleFactor(0.34) // no font size specified. Just let it be as large as possible and shrink it if needed
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                        .foregroundColor(backgroundBrightness.overwriteForegroundColor)
                        .opacity(backgroundBrightness.overwriteOpacityRoundedRectangle)
                        .frame(maxWidth: .infinity)
                    Text("Header Field")
                        .multilineTextAlignment(.center)
                        .foregroundColor(backgroundBrightness.overwriteForegroundColor)
                        .opacity(backgroundBrightness.overwriteOpacity)
                }
            }
        }
        .overlay {
            Button(action: {
                isCustomizeTextPresented.toggle()
            }) {
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.green, .white)
                    .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                    .font(.system(size: 18))
                    .offset(x: 9, y: 18)
                    .shadow(radius: 3, x: 0, y: 0)
            }
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
    EditableHeaderTextField(backgroundBrightness: .normal, disableButton: false, textLabel: .constant("HEADER"), text: .constant("TEST"), textColor: .black, labelColor: .black)
}
