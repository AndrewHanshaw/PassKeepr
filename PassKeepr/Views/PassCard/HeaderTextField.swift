import SwiftUI

struct HeaderTextField: View {
    var textLabel: String
    var text: String

    var textColor: Color
    var labelColor: Color

    var isCurrency: Bool
    var currencyCode: String

    @State private var isCustomizeTextPresented = false

    private var displayText: String {
        isCurrency ? formattedCurrencyText(text, currencyCode: currencyCode) : text
    }

    var body: some View {
        VStack {
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
                            Text(displayText)
                                .lineLimit(1)
                                .frame(alignment: .top)
                                .foregroundColor(textColor)
                                .disableAutocorrection(true)
                                .font(.system(size: 10))
                                .padding(0)
                                .padding(.leading, -10)
                                .minimumScaleFactor(0.34)
                                .textFieldLabelModifier()
                        }
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            Spacer()
        }
    }
}

#Preview {
    HeaderTextField(textLabel: "HEADER", text: "TEST", textColor: .black, labelColor: .black, isCurrency: false, currencyCode: "USD")
}
