import SwiftUI

struct ExpirationDatePicker: View {
    @Binding var pass: PassObject

    var disableControl: Bool

    @State private var showDatePicker: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Toggle("Expiration Date", isOn: $pass.hasExpirationDate)
                .onChange(of: pass.hasExpirationDate) {
                    withAnimation {
                        showDatePicker = pass.hasExpirationDate
                    }
                }
                .padding([.top, .bottom], 14)
                .overlay(alignment: .bottom) {
                    if showDatePicker {
                        Divider()
                    }
                }
                .padding([.leading, .trailing], 14)
                .disabled(disableControl)

            if showDatePicker {
                DatePicker(
                    "Expiration Date",
                    selection: $pass.expirationDate,
                    displayedComponents: [.date]
                )
                .disabled(disableControl)
                .transition(.opacity)
                .padding([.bottom, .leading, .trailing], 14)
                .datePickerStyle(.graphical)
            }
        }
        .listSectionBackgroundModifier()
        .onAppear {
            showDatePicker = pass.hasExpirationDate
        }
    }
}

#Preview {
    ExpirationDatePicker(pass: .constant(MockModelData().passObjects[0]), disableControl: false)
}
