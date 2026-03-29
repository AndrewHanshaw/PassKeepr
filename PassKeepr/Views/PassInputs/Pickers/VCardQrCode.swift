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
                    .padding([.top, .bottom], 10)
                    .padding([.leading, .trailing], 16)

                if passObject.vcardHasBirthday {
                    Divider()
                    DatePicker("Date", selection: $passObject.vcardBirthday, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding([.top, .bottom], 10)
                        .padding([.leading, .trailing], 16)
                }
            }
            .listSectionBackgroundModifier()

            LabeledContent {
                TextField("@handle or URL", text: $passObject.vcardSocial)
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

    static func formatVCard(from passObject: PassObject) -> String {
        formatVCard(
            firstName: passObject.vcardFirstName,
            lastName: passObject.vcardLastName,
            company: passObject.vcardCompany,
            phone: passObject.vcardPhone,
            email: passObject.vcardEmail,
            url: passObject.vcardURL,
            address: passObject.vcardAddress,
            birthday: passObject.vcardHasBirthday ? passObject.vcardBirthday : nil,
            social: passObject.vcardSocial,
            customFields: passObject.vcardCustomFields
        )
    }

    static func applyParsed(_ string: String, to passObject: inout PassObject) {
        let p = parseVCard(string)
        passObject.vcardFirstName = p.firstName
        passObject.vcardLastName = p.lastName
        passObject.vcardCompany = p.company
        passObject.vcardPhone = p.phone
        passObject.vcardEmail = p.email
        passObject.vcardURL = p.url
        passObject.vcardAddress = p.address
        passObject.vcardSocial = p.social
        passObject.vcardHasBirthday = p.birthday != nil
        passObject.vcardBirthday = p.birthday ?? Date()
        passObject.vcardCustomFields = p.customFields
    }

    static func formatVCard(
        firstName: String, lastName: String, company: String,
        phone: String, email: String,
        url: String, address: String,
        birthday: Date?, social: String,
        customFields: [VCardCustomField]
    ) -> String {
        var lines = ["BEGIN:VCARD", "VERSION:3.0"]

        let fn = [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")
        lines.append("N:\(escape(lastName));\(escape(firstName));;;")
        if !fn.isEmpty { lines.append("FN:\(escape(fn))") }
        if !company.isEmpty { lines.append("ORG:\(escape(company))") }
        if !phone.isEmpty { lines.append("TEL;TYPE=CELL:\(escape(phone))") }
        if !email.isEmpty { lines.append("EMAIL:\(escape(email))") }
        if !url.isEmpty { lines.append("URL:\(escape(url))") }
        if !address.isEmpty { lines.append("ADR;TYPE=HOME:;;\(escape(address));;;;") }
        if let birthday {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            lines.append("BDAY:\(formatter.string(from: birthday))")
        }
        if !social.isEmpty { lines.append("X-SOCIALPROFILE:\(escape(social))") }
        for field in customFields where !field.label.isEmpty || !field.value.isEmpty {
            let safeLabel = field.label.uppercased().replacingOccurrences(of: " ", with: "-")
            lines.append("X-CUSTOM-\(safeLabel):\(escape(field.value))")
        }

        lines.append("END:VCARD")
        return lines.joined(separator: "\n")
    }

    static func parseVCard(_ string: String) -> (
        firstName: String, lastName: String, company: String,
        phone: String, email: String,
        url: String, address: String, social: String,
        birthday: Date?, customFields: [VCardCustomField]
    ) {
        guard string.contains("BEGIN:VCARD") else {
            return ("", "", "", "", "", "", "", "", nil, [])
        }
        var firstName = ""
        var lastName = ""
        var company = ""
        var phone = ""
        var email = ""
        var url = ""
        var address = ""
        var social = ""
        var birthday: Date? = nil
        var customFields: [VCardCustomField] = []

        for line in string.components(separatedBy: .newlines) {
            let upperLine = line.uppercased()
            if upperLine.hasPrefix("N:") {
                let value = String(line.dropFirst(2))
                let parts = value.components(separatedBy: ";")
                lastName = parts.count > 0 ? unescape(parts[0]) : ""
                firstName = parts.count > 1 ? unescape(parts[1]) : ""
            } else if upperLine.hasPrefix("ORG:") {
                company = unescape(String(line.dropFirst(4)))
            } else if upperLine.hasPrefix("TEL") {
                if let colonIdx = line.firstIndex(of: ":") {
                    phone = unescape(String(line[line.index(after: colonIdx)...]))
                }
            } else if upperLine.hasPrefix("EMAIL:") {
                email = unescape(String(line.dropFirst(6)))
            } else if upperLine.hasPrefix("URL:") {
                url = unescape(String(line.dropFirst(4)))
            } else if upperLine.hasPrefix("ADR") {
                if let colonIdx = line.firstIndex(of: ":") {
                    let addrValue = String(line[line.index(after: colonIdx)...])
                    let parts = addrValue.components(separatedBy: ";")
                    address = parts.count > 2 ? unescape(parts[2]) : unescape(addrValue)
                }
            } else if upperLine.hasPrefix("BDAY:") {
                let dateStr = String(line.dropFirst(5))
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMdd"
                birthday = formatter.date(from: dateStr)
                if birthday == nil {
                    formatter.dateFormat = "yyyy-MM-dd"
                    birthday = formatter.date(from: dateStr)
                }
            } else if upperLine.hasPrefix("X-SOCIALPROFILE:") {
                social = unescape(String(line.dropFirst(16)))
            } else if upperLine.hasPrefix("X-CUSTOM-") {
                if let colonIdx = line.firstIndex(of: ":") {
                    let labelPart = String(line[line.index(line.startIndex, offsetBy: 9) ..< colonIdx])
                    let valuePart = String(line[line.index(after: colonIdx)...])
                    customFields.append(VCardCustomField(label: labelPart, value: unescape(valuePart)))
                }
            }
        }
        return (firstName, lastName, company, phone, email, url, address, social, birthday, customFields)
    }

    private static func escape(_ s: String) -> String {
        s
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: ";", with: "\\;")
            .replacingOccurrences(of: ",", with: "\\,")
            .replacingOccurrences(of: "\n", with: "\\n")
    }

    private static func unescape(_ s: String) -> String {
        var result = ""
        var iter = s.makeIterator()
        while let ch = iter.next() {
            if ch == "\\" {
                if let next = iter.next() {
                    switch next {
                    case "n", "N": result.append("\n")
                    case ";": result.append(";")
                    case ",": result.append(",")
                    case "\\": result.append("\\")
                    default:
                        result.append("\\")
                        result.append(next)
                    }
                } else {
                    result.append("\\")
                }
            } else {
                result.append(ch)
            }
        }
        return result
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
