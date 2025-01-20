import SwiftUI

struct SecondaryFieldSelection: View {
    @State private var shouldShowThirdSecondaryField: Bool = false // This state var, which shall always track the state of passObject.isSecondaryFieldTwoOn, is necessary for the animation to work
    @Binding var passObject: PassObject

    var body: some View {
        Section {
            Toggle("Additional Secondary Field", isOn: $passObject.isSecondaryFieldTwoOn)
                .onChange(of: passObject.isSecondaryFieldTwoOn) {
                    withAnimation {
                        shouldShowThirdSecondaryField = passObject.isSecondaryFieldTwoOn
                        if !passObject.isSecondaryFieldTwoOn {
                            passObject.isSecondaryFieldThreeOn = false
                        }
                    }
                }

            if shouldShowThirdSecondaryField {
                Toggle("Additional Secondary Field", isOn: $passObject.isSecondaryFieldThreeOn)
                    .transition(.slide)
            }
        }
        .onAppear {
            shouldShowThirdSecondaryField = passObject.isSecondaryFieldTwoOn
        }
    }
}

#Preview {
    SecondaryFieldSelection(passObject: .constant(MockModelData().passObjects[0]))
}
