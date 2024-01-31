//
//  NoteInput.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 1/10/24.
//

import SwiftUI

struct NoteInput: View {
    @Binding var noteInput: String

    var body: some View {
        Section {
            TextField("Note", text: $noteInput, axis: .vertical)
                .lineLimit(5...10)
        } footer: {Text("Notes should be less than XXX characters")
        }
    }
}

#Preview {
    NoteInput(noteInput: .constant("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."))
}
