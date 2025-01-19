import SwiftUI

struct SecondaryTextField: View {
    @Binding var textLabel: String
    @Binding var text: String
    var isStripImageOn: Bool

    @State private var textSize: CGSize = CGSizeZero
    @State private var labelSize: CGSize = CGSizeZero

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
                    .readSize(into: $labelSize)

                Text(text)
                    .lineLimit(1)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .foregroundColor(textColor)
                    .disableAutocorrection(true)
                    .font(.system(size: isStripImageOn ? 28 : 20))
                    .fontWeight(.thin)
                    .padding(0)
                    .padding(.top, 7)
                    .minimumScaleFactor(0.34)
                    .readSize(into: $textSize)
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                    .frame(maxHeight: .infinity)
                    .aspectRatio(2, contentMode: .fit)
            }

            Button(action: {
                isCustomizeTextPresented.toggle()
            }) {
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.green, .white)
                    .frame(maxWidth: (textSize.width < labelSize.width) ? labelSize.width : textSize.width /* for whatver reason, I can't seem to read the size of the ZStack that this view is contained in. This logic allows for the button to expand and shrink based on the text and label without using an infinity frame maxwidth (which breaks  */, maxHeight: textSize.height /* height is the same for both*/, alignment: .bottomTrailing)
                    .font(.system(size: 18))
                    .shadow(radius: 3, x: 0, y: 0)
            }
            .offset(x: 9, y: 9)
            .buttonStyle(PlainButtonStyle())
        }
        .popover(isPresented: $isCustomizeTextPresented, arrowEdge: .top) {
            CustomizePassTextField(textLabel: $textLabel, text: $text)
                .presentationCompactAdaptation((.popover))
        }
        .padding(.trailing, -5)
    }
}

#Preview {
    SecondaryTextField(textLabel: .constant("HEADER"), text: .constant("TEST"), isStripImageOn: true, textColor: .black, labelColor: .black)
}
