import SwiftUI

struct PassGroupPicker: View {
    @Binding var pass: PassObject

    var disableControl: Bool

    @State private var showAlert = false
    @State private var group: Int

    init(pass: Binding<PassObject>, disableControl: Bool) {
        _pass = pass
        self.disableControl = disableControl
        _group = State(initialValue: pass.wrappedValue.group)
    }

    var body: some View {
        HStack(spacing: 0) {
            Text("Pass Group")
            Spacer()
            Picker("Pass Group", selection: $group) {
                ForEach(1 ... 10, id: \.self) { group in
                    Text("\(group)")
                }
            }
            .disabled(disableControl)
            .accentColor(.secondary)

            Button(
                action: {
                    showAlert = true
                },
                label: {
                    Image(systemName: "info.circle")
                        .foregroundColor(.secondary)
                }
            )
            .buttonStyle(PlainButtonStyle())
            .padding(.trailing, 12)
        }
        .onChange(of: group) {
            pass.group = group
        }
        .padding([.top, .bottom], 10)
        .padding(.trailing, 4)
        .padding(.leading, 12)
        .listSectionBackgroundModifier() // necessary?
        .alert("Pass Group", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The Pass Group is used to separate passes once added to Wallet.")
        }
    }
}

#Preview {
    PassGroupPicker(pass: .constant(MockModelData().passObjects[0]), disableControl: false)
}
