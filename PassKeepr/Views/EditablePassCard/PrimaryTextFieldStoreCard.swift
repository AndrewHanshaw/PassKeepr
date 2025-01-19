// This field only applies to Store Cards, which for some reason display the text much larger than normal, and also displays the label below the text
// This text field also takes up more of the overall pass, about 15% over the normal 10% for a primary field
import SwiftUI

struct PrimaryTextFieldStoreCard: View {
    @Binding var textLabel: String
    @Binding var text: String

    var textColor: Color
    var labelColor: Color

    @State private var isCustomizeTextPresented = false

    var body: some View {
        ZStack {
            if textLabel != "" || text != "" {
                HStack {
                    Text(text)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .foregroundColor(textColor)
                        .disableAutocorrection(true)
                        .font(.system(size: 36))
                        .padding(0)
                    Spacer()
                }

                HStack {
                    Text(textLabel)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .foregroundColor(labelColor)
                        .disableAutocorrection(true)
                        .textCase(.uppercase)
                        .font(.system(size: 20))
                        .padding(0)
                    Spacer()
                }
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                    .frame(maxHeight: .infinity)
            }

            Button(action: {
                isCustomizeTextPresented.toggle()
            }) {
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.green, .white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .font(.system(size: 18))
                    .shadow(radius: 3, x: 0, y: 0)
            }
            .offset(x: 9, y: 9)
            .buttonStyle(PlainButtonStyle())
        }
        .popover(isPresented: $isCustomizeTextPresented, arrowEdge: .leading) {
            CustomizePassTextField(textLabel: $textLabel, text: $text)
                .presentationCompactAdaptation((.popover))
        }
    }
}

#Preview {
    PrimaryTextFieldStoreCard(textLabel: .constant("HEADER"), text: .constant("TEST"), textColor: .black, labelColor: .black)
}
