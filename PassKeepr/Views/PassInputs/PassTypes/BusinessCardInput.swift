import SwiftUI

struct BusinessCardInput: View {
    @Binding var passObject: PassObject

    var body: some View {
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
