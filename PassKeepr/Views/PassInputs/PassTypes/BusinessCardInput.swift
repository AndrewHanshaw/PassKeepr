import SwiftUI

struct BusinessCardInput: View {
    @Binding var passObject: PassObject

    @State private var isPhotoPrimaryFieldSelected = true

    var body: some View {
        Section {
            VStack {
                Text("Primary Field Type:")
                    .padding(5)
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isPhotoPrimaryFieldSelected ? Color.accentColor : Color.white)
                            .stroke(isPhotoPrimaryFieldSelected ? Color.clear : Color.gray, lineWidth: 1)
                        Text("Photo")
                            .foregroundColor(isPhotoPrimaryFieldSelected ? .white : .gray)
                            .fontWeight(isPhotoPrimaryFieldSelected ? .bold : .regular)
                    }
                    .opacity(isPhotoPrimaryFieldSelected ? 1 : 0.5)
                    .animation(.easeInOut(duration: 0.1), value: isPhotoPrimaryFieldSelected)
                    .onTapGesture {
                        isPhotoPrimaryFieldSelected = true
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(!isPhotoPrimaryFieldSelected ? Color.accentColor : Color.white)
                            .stroke(!isPhotoPrimaryFieldSelected ? Color.clear : Color.gray, lineWidth: 1)
                        Text("Text")
                            .foregroundColor(!isPhotoPrimaryFieldSelected ? .white : .gray)
                            .fontWeight(!isPhotoPrimaryFieldSelected ? .bold : .regular)
                    }
                    .opacity(!isPhotoPrimaryFieldSelected ? 1 : 0.5)
                    .animation(.easeInOut(duration: 0.1), value: isPhotoPrimaryFieldSelected)
                    .onTapGesture {
                        isPhotoPrimaryFieldSelected = false
                    }
                }
                .padding(.bottom, 5)
            }
        }

        Section {
            LabeledContent {
                TextField("Name", text: $passObject.name)
            } label: {
                Text("Name")
            }
            LabeledContent {
                TextField("Optional", text: $passObject.title)
            } label: {
                Text("Title")
            }
            LabeledContent {
                TextField("Optional", text: $passObject.businessName)
            } label: {
                Text("Business Name")
            }
            LabeledContent {
                TextField("Optional", text: $passObject.phoneNumber)
            } label: {
                Text("Phone Number")
            }
            LabeledContent {
                TextField("Optional", text: $passObject.email)
            } label: {
                Text("Email Address")
            }
        }
    }
}

#Preview {
    BusinessCardInput(passObject: .constant(MockModelData().passObjects[0]))
}
