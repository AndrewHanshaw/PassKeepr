import SwiftUI

struct SecondaryTextField: View {
    var placeholderColor: Color
    var disableButton: Bool

    @Binding var textLabel: String
    @Binding var text: String
    var isStripImageOn: Bool

    var textColor: Color
    var labelColor: Color

    @State private var isCustomizeTextPresented = false

    var body: some View {
        ZStack(alignment: .leading) {
            if textLabel != "" || text != "" {
                Text(textLabel)
                    .lineLimit(1)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .foregroundColor(labelColor)
                    .disableAutocorrection(true)
                    .textCase(.uppercase)
                    .font(.system(size: 11))
                    .fontWeight(.semibold)
                    .padding(0)
                    .padding(.top, -2)

                Text(text)
                    .lineLimit(1)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .foregroundColor(textColor)
                    .disableAutocorrection(true)
                    .font(.system(size: isStripImageOn ? 28 : 20))
                    .fontWeight(.thin)
                    .padding(0)
                    .padding(.top, 8)
                    .minimumScaleFactor(0.34)
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                    .foregroundColor(placeholderColor)
                    .opacity(placeholderColor == Color.gray ? 0.5 : 0.3)
                    .aspectRatio(2, contentMode: .fit)
                Text("Secondary\nField")
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.34)
                    .foregroundColor(placeholderColor)
                    .opacity(placeholderColor == Color.gray ? 0.7 : 0.4)
                    .padding(2)
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
        .padding(.trailing, -5)
    }
}

#Preview {
    SecondaryTextField(placeholderColor: Color.black, disableButton: false, textLabel: .constant("HEADER"), text: .constant("TEST"), isStripImageOn: true, textColor: .black, labelColor: .black)
}
