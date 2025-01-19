import SwiftUI

struct SecondaryFieldSelection: View {
    @State private var shouldShowSecondSecondaryField: Bool = false
    @State private var shouldShowThirdSecondaryField: Bool = false
    @Binding var passObject: PassObject

    var body: some View {
        Section {
            withAnimation {
                Toggle(isOn: $passObject.isSecondaryFieldOneOn) {
                    Text("Secondary Field")
                }
            }
            .onChange(of: passObject.isSecondaryFieldOneOn) {
                if !passObject.isSecondaryFieldOneOn {
                    passObject.isSecondaryFieldTwoOn = false
                }
                withAnimation { shouldShowSecondSecondaryField = passObject.isSecondaryFieldOneOn }
            }

            if shouldShowSecondSecondaryField {
                Toggle(isOn: $passObject.isSecondaryFieldTwoOn) {
                    Text("Additional Secondary Field")
                }
                .transition(.slide)
            }

            if shouldShowThirdSecondaryField {
                Toggle(isOn: $passObject.isSecondaryFieldThreeOn) {
                    Text("Additional Secondary Field")
                }
                .transition(.slide)
            }
        }
        .onAppear {
            shouldShowSecondSecondaryField = passObject.isSecondaryFieldOneOn
            shouldShowThirdSecondaryField = passObject.isSecondaryFieldTwoOn && passObject.isSecondaryFieldOneOn
        }
    }
}

#Preview {
    SecondaryFieldSelection(passObject: .constant(ModelData().passObjects[0]))
}
