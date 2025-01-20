import SwiftUI

struct PassCardTopSection: View {
    var passObject: PassObject
    @State private var viewSize: CGSize = CGSizeZero

    var body: some View {
        GeometryReader { _ in
            HStack {
                if passObject.logoImage != Data() {
                    VStack {
                        Image(uiImage: UIImage(data: passObject.logoImage)!)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 30)
                            .padding([.top, .leading], 8)
                        Spacer()
                    }
                }
                Spacer()
                if passObject.headerFieldOneLabel != "" && passObject.headerFieldOneText != "" {
                    HeaderTextField(textLabel: passObject.headerFieldOneLabel, text: passObject.headerFieldOneText, textColor: Color(hex: passObject.foregroundColor), labelColor: Color(hex: passObject.labelColor))
                        .padding(.top, 5)
                }
            }
            .padding(.trailing, 10)
        }
    }
}

#Preview {
    PassCardTopSection(passObject: MockModelData().passObjects[0])
}
