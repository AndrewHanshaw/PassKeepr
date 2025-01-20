import SwiftUI

struct EditableHeaderTextField: View {
    var placeholderColor: Color
    @Binding var textLabel: String
    @Binding var text: String

    var textColor: Color
    var labelColor: Color

    @State private var isCustomizeTextPresented = false

    var body: some View {
        VStack {
            ZStack {
                if textLabel != "" || text != "" {
                    HStack(alignment: .top) {
                        Spacer()
                        VStack {
                            HStack {
                                Spacer()
                                Text(textLabel)
                                    .lineLimit(1)
                                    .frame(alignment: .top)
                                    .foregroundColor(labelColor)
                                    .disableAutocorrection(true)
                                    .textCase(.uppercase)
                                    .font(.system(size: 11))
                                    .fontWeight(.semibold)
                                    .padding(0)
                                    .padding(.leading, -20)
//                                    .minimumScaleFactor(0.34) // TODO: Is this needed?
                            }

                            HStack {
                                Spacer()
                                Text(text)
                                    .lineLimit(1)
                                    .frame(alignment: .top)
                                    .foregroundColor(textColor)
                                    .disableAutocorrection(true)
                                    .font(.system(size: 20))
                                    .padding(0)
                                    .padding(.leading, -20)
                                    .minimumScaleFactor(0.34)
                            }
                            Spacer()
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                        .foregroundColor(placeholderColor)
                        .opacity(placeholderColor == Color.gray ? 0.5 : 0.3)
                        .frame(maxWidth: .infinity)
                    Text("Header Field")
                        .multilineTextAlignment(.center)
                        .foregroundColor(placeholderColor)
                        .opacity(placeholderColor == Color.gray ? 0.7 : 0.4)
                }

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
            }
            .frame(maxWidth: .infinity)
            .popover(isPresented: $isCustomizeTextPresented, arrowEdge: .top) {
                CustomizePassTextField(textLabel: $textLabel, text: $text)
                    .presentationCompactAdaptation((.popover))
            }
            Spacer()
        }
    }
}

#Preview {
    EditableHeaderTextField(placeholderColor: Color.black, textLabel: .constant("HEADER"), text: .constant("TEST"), textColor: .black, labelColor: .black)
}
