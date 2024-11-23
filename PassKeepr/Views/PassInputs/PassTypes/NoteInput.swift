import SwiftUI

struct NoteInput: View {
    @Binding var passObject: PassObject

    var body: some View {
        Section {
            TextField("Note", text: $passObject.noteString, axis: .vertical)
                .lineLimit(5 ... 10)
        } footer: { Text("Notes should be less than XXX characters")
        }
    }
}

#Preview {
    NoteInput(passObject: .constant(MockModelData().passObjects[0]))
}
