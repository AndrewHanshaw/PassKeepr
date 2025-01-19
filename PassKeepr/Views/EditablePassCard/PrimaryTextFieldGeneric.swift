import SwiftUI

struct PrimaryTextFieldGeneric: View {
    @Binding var textLabel: String
    @Binding var text: String

    var textColor: Color
    var labelColor: Color

    @State private var isCustomizeTextPresented = false

    var body: some View {
        ZStack {
            if textLabel != "" || text != "" {
                HStack {
                    Text(textLabel)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .foregroundColor(labelColor)
                        .disableAutocorrection(true)
                        .textCase(.uppercase)
                        .font(.system(size: 12))
                        .padding(0)
                        .padding(.top, -2)
                    Spacer()
                }

                HStack {
                    Text(text)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .foregroundColor(textColor)
                        .disableAutocorrection(true)
                        .font(.system(size: 30))
                        .padding(0)
                        .padding(.bottom, -6)
                    Spacer()
                }
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .font(.system(size: 18))
                    .shadow(color: .gray, radius: 3, x: 0, y: 0)
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
    PrimaryTextFieldGeneric(textLabel: .constant("HEADER"), text: .constant("TEST"), textColor: .black, labelColor: .black)
}
