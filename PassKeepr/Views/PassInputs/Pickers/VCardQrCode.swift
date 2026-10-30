import PassKeeprCore
import SwiftUI

struct VCardQrCode: View {
    @Binding var passObject: PassObject

    var body: some View {
        VStack(spacing: 20) {
            LabeledContent {
                TextField("First", text: $passObject.vcardFirstName)
                    .disableAutocorrection(true)
            } label: {
                Text("First Name")
            }
            .padding(16)
            .listSectionBackgroundModifier()

            LabeledContent {
                TextField("Last", text: $passObject.vcardLastName)
                    .disableAutocorrection(true)
            } label: {
                Text("Last Name")
            }
            .padding(16)
            .listSectionBackgroundModifier()

            LabeledContent {
                TextField("Company", text: $passObject.vcardCompany)
                    .disableAutocorrection(true)
            } label: {
                Text("Company")
            }
            .padding(16)
            .listSectionBackgroundModifier()

            LabeledContent {
                TextField("Phone", text: $passObject.vcardPhone)
                    .keyboardType(.phonePad)
            } label: {
                Text("Phone")
            }
            .padding(16)
            .listSectionBackgroundModifier()

            LabeledContent {
                TextField("Email", text: $passObject.vcardEmail)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
            } label: {
                Text("Email")
            }
            .padding(16)
            .listSectionBackgroundModifier()

            LabeledContent {
                TextField("https://...", text: $passObject.vcardURL)
                    .keyboardType(.URL)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
            } label: {
                Text("URL")
            }
            .padding(16)
            .listSectionBackgroundModifier()

            LabeledContent {
                TextField("Address", text: $passObject.vcardAddress, axis: .vertical)
                    .disableAutocorrection(true)
                    .lineLimit(1 ... 4)
            } label: {
                Text("Address")
            }
            .padding(16)
            .listSectionBackgroundModifier()

            VStack(spacing: 0) {
                Toggle("Birthday", isOn: $passObject.vcardHasBirthday)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)

                if passObject.vcardHasBirthday {
                    Divider()
                    DatePicker("Date", selection: $passObject.vcardBirthday, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                }
            }
            .listSectionBackgroundModifier()

            LabeledContent {
                TextField("Handle or URL", text: $passObject.vcardSocial)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
            } label: {
                Text("Social")
            }
            .padding(16)
            .listSectionBackgroundModifier()

            ForEach($passObject.vcardCustomFields) { $field in
                HStack(spacing: 8) {
                    Button {
                        passObject.vcardCustomFields.removeAll { $0.id == field.id }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                    }
                    TextField("Label", text: $field.label)
                        .disableAutocorrection(true)
                        .frame(maxWidth: 100)
                    Divider()
                    TextField("Value", text: $field.value)
                        .disableAutocorrection(true)
                }
                .padding(16)
                .listSectionBackgroundModifier()
            }

            Button {
                passObject.vcardCustomFields.append(VCardCustomField())
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Custom Field")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color(.label))
            }
            .padding(16)
            .listSectionBackgroundModifier()
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            VCardQrCode(passObject: .constant(PassObject()))
        }
        .padding()
    }
}
