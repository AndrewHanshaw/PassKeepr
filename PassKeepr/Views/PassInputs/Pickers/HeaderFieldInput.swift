import SwiftUI

struct HeaderFieldSelection: View {
    @State private var shouldShowAdditionalHeaderField: Bool = false
    @Binding var passObject: PassObject

    var body: some View {
        Section {
            withAnimation {
                Toggle(isOn: $passObject.isHeaderFieldOneOn) {
                    Text("Header Field")
                }
            }
            .onChange(of: passObject.isHeaderFieldOneOn) {
                if !passObject.isHeaderFieldOneOn {
                    passObject.isHeaderFieldTwoOn = false
                }
                withAnimation { shouldShowAdditionalHeaderField = passObject.isHeaderFieldOneOn }
            }

            if shouldShowAdditionalHeaderField {
                Toggle(isOn: $passObject.isHeaderFieldTwoOn) {
                    Text("Additional Header Field")
                }
                .transition(.slide)
            }
        }
        .onAppear {
            shouldShowAdditionalHeaderField = passObject.isHeaderFieldOneOn
        }
    }
}

#Preview {
    HeaderFieldSelection(passObject: .constant(ModelData().passObjects[0]))
}
