import SwiftUI

struct SecondaryFieldSelection: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var passObject: PassObject

    @State private var shouldShowThirdSecondaryField: Bool = false // This state var, which shall always track the state of passObject.isSecondaryFieldTwoOn, is necessary for the animation to work

    var body: some View {
        VStack(spacing: 12) {
            Toggle("Additional Secondary Field", isOn: $passObject.isSecondaryFieldTwoOn)
                .onChange(of: passObject.isSecondaryFieldTwoOn) {
                    withAnimation {
                        shouldShowThirdSecondaryField = passObject.isSecondaryFieldTwoOn
                        if !passObject.isSecondaryFieldTwoOn {
                            passObject.isSecondaryFieldThreeOn = false
                        }
                    }
                }
                .padding([.top, .bottom], 14)
                .overlay(alignment: .bottom) {
                    if shouldShowThirdSecondaryField {
                        Divider()
                    }
                }
                .padding([.leading, .trailing], 14)

            if shouldShowThirdSecondaryField {
                Toggle("Additional Secondary Field", isOn: $passObject.isSecondaryFieldThreeOn)
                    .transition(.opacity)
                    .padding([.bottom], 14)
                    .padding([.leading, .trailing], 14)
            }
        }
        .listSectionBackgroundModifier()
        .onAppear {
            shouldShowThirdSecondaryField = passObject.isSecondaryFieldTwoOn
        }
    }
}

#Preview {
    SecondaryFieldSelection(passObject: .constant(MockModelData().passObjects[0]))
}
