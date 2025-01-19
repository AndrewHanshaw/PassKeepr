import SwiftUI

struct EditablePassCardTopSection: View {
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
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                            .aspectRatio(3.2, contentMode: .fit)
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
                            .shadow(color: .gray, radius: 2, x: 0, y: 0)
                    }
                }
                .frame(maxWidth: geometry.size.width * 0.64)
                .fixedSize(horizontal: true, vertical: false)
                .sheet(isPresented: $isCustomizeLogoImagePresented) {
                    CustomizeLogoImage(passObject: $passObject)
                        .edgesIgnoringSafeArea(.bottom)
                        .presentationDragIndicator(.visible)
                }

                Spacer()
                HStack {
                    if passObject.isHeaderFieldTwoOn {
                        HeaderTextField(textLabel: $passObject.headerFieldTwoLabel, text: $passObject.headerFieldTwoText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                            .padding(.trailing, 5)
                    }

                    // Header field 1 is to the *right* of header field 2
                    if passObject.isHeaderFieldOneOn {
                        HeaderTextField(textLabel: $passObject.headerFieldOneLabel, text: $passObject.headerFieldOneText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                            .padding(.trailing, 5)
                    }
                }
                .frame(width: geometry.size.width * 0.36)
            }
            .frame(width: geometry.size.width)
        }
    }
}

#Preview {
    EditablePassCardTopSection(passObject: .constant(MockModelData().passObjects[0]), isCustomizeLogoImagePresented: .constant(false))
}
