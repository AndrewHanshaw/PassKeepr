import SwiftUI

struct EditablePassCardTopSection: View {
    var placeholderColor: Color
    var disableButtons: Bool

    @Binding var passObject: PassObject
    @Binding var isCustomizeLogoImagePresented: Bool

    var body: some View {
        GeometryReader { geometry in
            HStack {
                ZStack {
                    if passObject.logoImage != Data() {
                        Image(uiImage: UIImage(data: passObject.logoImage)!)
                            .resizable()
                            .scaledToFit()
                            .frame(alignment: .leading)
                            .fixedSize(horizontal: true, vertical: false)
                    } else {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                            .aspectRatio(3, contentMode: .fit)
                            .foregroundColor(placeholderColor)
                            .opacity(placeholderColor == Color.gray ? 0.5 : 0.3)
                        Text("Logo Image")
                            .foregroundColor(placeholderColor)
                            .opacity(placeholderColor == Color.gray ? 0.7 : 0.4)
                    }

                    Button(action: {
                        isCustomizeLogoImagePresented.toggle()
                    }) {
                        Image("custom.photo.circle.fill")
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.green, .white)
                            .font(.system(size: 24))
                            .offset(x: 12, y: 12)
                            .shadow(radius: 2, x: 0, y: 0)
                    }
                    .disabled(disableButtons)
                }
                .frame(maxWidth: geometry.size.width * 0.64)
                .fixedSize(horizontal: true, vertical: false)
                .sheet(isPresented: $isCustomizeLogoImagePresented) {
                    CustomizeLogoImage(passObject: $passObject, placeholderColor: placeholderColor)
                        .edgesIgnoringSafeArea(.bottom)
                        .presentationDragIndicator(.visible)
                }

                Spacer()
                HStack {
                    if passObject.isHeaderFieldTwoOn {
                        EditableHeaderTextField(placeholderColor: placeholderColor, disableButton: disableButtons, textLabel: $passObject.headerFieldTwoLabel, text: $passObject.headerFieldTwoText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                            .padding(.trailing, 10)
                    }

                    EditableHeaderTextField(placeholderColor: placeholderColor, disableButton: disableButtons, textLabel: $passObject.headerFieldOneLabel, text: $passObject.headerFieldOneText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                        .padding(.trailing, 5)
                }
                .padding(.top, 4)
                .frame(width: geometry.size.width * 0.36)
            }
            .frame(width: geometry.size.width)
        }
    }
}

#Preview {
    EditablePassCardTopSection(placeholderColor: Color.black, disableButtons: false, passObject: .constant(MockModelData().passObjects[0]), isCustomizeLogoImagePresented: .constant(false))
}
