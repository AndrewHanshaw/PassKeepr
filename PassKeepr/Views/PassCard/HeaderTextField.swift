import SwiftUI

struct HeaderTextField: View {
    var textLabel: String
    var text: String

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
                                    .font(.system(size: 8))
                                    .fontWeight(.semibold)
                                    .padding(0)
                                    .padding(.leading, -10)
                                    .keyboardType(.asciiCapable)
//                                    .minimumScaleFactor(0.34) // TODO: Is this needed?
                            }

                            HStack {
                                Spacer()
                                Text(text)
                                    .lineLimit(1)
                                    .frame(alignment: .top)
                                    .foregroundColor(textColor)
                                    .disableAutocorrection(true)
                                    .font(.system(size: 10))
                                    .padding(0)
                                    .padding(.leading, -10)
                                    .minimumScaleFactor(0.34)
                            }
                            Spacer()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            Spacer()
        }
    }
}

#Preview {
    HeaderTextField(textLabel: "HEADER", text: "TEST", textColor: .black, labelColor: .black)
}
