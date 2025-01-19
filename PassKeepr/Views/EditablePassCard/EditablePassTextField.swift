import SwiftUI

struct EditablePassTextField: View {
    @State var textFieldTitle: String
    @Binding var textToEdit: String

    @Binding var textColor: Color
    @Binding var labelColor: Color

    @State private var isEditing: Bool = false
    @FocusState private var isTextFieldFocused: Bool

    init(
        textFieldTitle: String,
        textToEdit: Binding<String>,
        textColor: Binding<Color>? = nil,
        labelColor: Binding<Color>? = nil
    ) {
        self.textFieldTitle = textFieldTitle
        _textToEdit = textToEdit
        // Provide a default value for textColor if nil
        if let textColor = textColor {
            _textColor = textColor
        } else {
            _textColor = .constant(.black) // Default color
        }

        if let labelColor = labelColor {
            _labelColor = labelColor
        } else {
            _labelColor = .constant(.black) // Default color
        }
    }

    var body: some View {
        ZStack {
            VStack {
                Text(textFieldTitle)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .foregroundColor(labelColor)
                    .font(.system(size: 12))
                    .frame(height: UIFont.systemFont(ofSize: 10).lineHeight)
                Spacer()
            }
            .frame(height: 35)

            VStack {
                Spacer()
                HStack {
                    TextFieldDynamicWidth(title: textFieldTitle, text: $textToEdit, onEditingChanged: { isFocused in
                        if isFocused {
                            isEditing = true
                        } else {
                            isEditing = false
                        }
                    }, onCommit: {
                        isEditing = false
                    })
                    .frame(height: UIFont.systemFont(ofSize: 18).lineHeight) // For some reason, if the TextField's text is too long for the view to the point of showing an ellipse, it makes it much taller. This restriction keeps it the normal height.
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isTextFieldFocused)
                    .disableAutocorrection(true)
                    .font(.system(size: 18))
                    .padding(.vertical, 0)
                    .foregroundColor(textColor)

                    if isEditing == false {
                        Button(action: {
                            isTextFieldFocused = true // Programmatically focus TextField
                        }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 15))
                                .padding(.leading, -4)
                        }
                    }
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .bottomLeading)
            .frame(height: 35)
        }
        .frame(height: 35)
    }
}

#Preview {
    EditablePassTextField(textFieldTitle: "TEST", textToEdit: .constant("TEST"))
}
