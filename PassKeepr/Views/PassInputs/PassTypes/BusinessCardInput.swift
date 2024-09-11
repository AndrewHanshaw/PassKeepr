//
//  BusinessCardInput.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 1/10/24.
//

import SwiftUI

struct BusinessCardInput: View {
    @Binding var nameInput: String
    @Binding var titleInput: String
    @Binding var businessNameInput: String
    @Binding var phoneNumberInput: String
    @Binding var emailInput: String

    var body: some View {
        Section {
            LabeledContent {
                TextField("Name", text: $nameInput)
            } label: {
                Text("Name")
            }
            LabeledContent {
                TextField("Optional", text: $titleInput)
            } label: {
                Text("Title")
            }
            LabeledContent {
                TextField("Optional", text: $businessNameInput)
            } label: {
                Text("Business Name")
            }
            LabeledContent {
                TextField("Optional", text: $phoneNumberInput)
            } label: {
                Text("Phone Number")
            }
            LabeledContent {
                TextField("Optional", text: $emailInput)
            } label: {
                Text("Email Address")
            }
        }
    }
}

#Preview {
    BusinessCardInput(nameInput: .constant("Test Name"), titleInput: .constant("Test Title"), businessNameInput: .constant("Test Business"), phoneNumberInput: .constant("(111) 222-3333"), emailInput: .constant("test@test.com"))
}
