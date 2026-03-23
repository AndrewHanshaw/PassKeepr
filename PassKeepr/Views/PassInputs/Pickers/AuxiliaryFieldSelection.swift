import SwiftUI

struct AuxiliaryFieldSelection: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var passObject: PassObject

    var disableControl: Bool

    @State private var shouldShowThirdAuxiliaryField: Bool = false // This state var, which shall always track the state of passObject.isAuxiliaryFieldTwoOn, is necessary for the animation to work

    var body: some View {
        VStack(spacing: 12) {
            Toggle("Additional Auxiliary Field", isOn: $passObject.isAuxiliaryFieldTwoOn)
                .onChange(of: passObject.isAuxiliaryFieldTwoOn) {
                    withAnimation {
                        shouldShowThirdAuxiliaryField = passObject.isAuxiliaryFieldTwoOn
                        if !passObject.isAuxiliaryFieldTwoOn {
                            passObject.isAuxiliaryFieldThreeOn = false
                        }
                    }
                }
                .padding([.top, .bottom], 14)
                .overlay(alignment: .bottom) {
                    if shouldShowThirdAuxiliaryField {
                        Divider()
                    }
                }
                .padding([.leading, .trailing], 14)
                .disabled(disableControl)

            if shouldShowThirdAuxiliaryField {
                Toggle("Additional Auxiliary Field", isOn: $passObject.isAuxiliaryFieldThreeOn)
                    .transition(.opacity)
                    .padding([.bottom], 14)
                    .padding([.leading, .trailing], 14)
                    .disabled(disableControl)
            }
        }
        .listSectionBackgroundModifier()
        .onAppear {
            shouldShowThirdAuxiliaryField = passObject.isAuxiliaryFieldTwoOn
        }
    }
}

#Preview {
    AuxiliaryFieldSelection(passObject: .constant(MockModelData().passObjects[0]), disableControl: false)
}
