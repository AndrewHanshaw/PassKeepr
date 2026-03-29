import SwiftUI

struct SecondaryFieldSelection: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var passObject: PassObject

    var disableControl: Bool

    @State private var shouldShowThirdSecondaryField: Bool = false // This state var, which shall always track the state of passObject.isSecondaryFieldTwoOn, is necessary for the animation to work
    @State private var shouldShowCappedFootnote: Bool = false // This state var, which shall always track the state of isCapped, is necessary for the animation to work

    private var totalCombinedFieldCount: Int {
        1 // secondaryFieldOne is always on
            + (passObject.isSecondaryFieldTwoOn ? 1 : 0)
            + (passObject.isSecondaryFieldThreeOn ? 1 : 0)
            + (passObject.isAuxiliaryFieldOneOn ? 1 : 0)
            + (passObject.isAuxiliaryFieldTwoOn ? 1 : 0)
            + (passObject.isAuxiliaryFieldThreeOn ? 1 : 0)
    }

    private var isCapped: Bool {
        passObject.isCustomStripImageOn && totalCombinedFieldCount >= 4 && !(passObject.isSecondaryFieldTwoOn && passObject.isSecondaryFieldThreeOn)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 12) {
                Toggle("Additional Secondary Field", isOn: $passObject.isSecondaryFieldTwoOn)
                    .onChange(of: passObject.isSecondaryFieldTwoOn) {
                        withAnimation {
                            shouldShowThirdSecondaryField = passObject.isSecondaryFieldTwoOn && !isCapped
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
                    .disabled(disableControl || (isCapped && !passObject.isSecondaryFieldTwoOn))

                if shouldShowThirdSecondaryField {
                    Toggle("Additional Secondary Field", isOn: $passObject.isSecondaryFieldThreeOn)
                        .transition(.opacity)
                        .padding([.bottom], 14)
                        .padding([.leading, .trailing], 14)
                        .disabled(disableControl || (isCapped && !passObject.isSecondaryFieldThreeOn))
                }
            }
            .listSectionBackgroundModifier()
            .onAppear {
                shouldShowCappedFootnote = isCapped
                shouldShowThirdSecondaryField = passObject.isSecondaryFieldTwoOn && !isCapped
            }
            .onChange(of: isCapped) {
                withAnimation {
                    shouldShowCappedFootnote = isCapped
                    shouldShowThirdSecondaryField = passObject.isSecondaryFieldTwoOn && !isCapped
                }
            }

            if shouldShowCappedFootnote {
                Text("Secondary and auxiliary fields are limited to 4 combined when a strip image is used.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.leading, 14)
                    .transition(.opacity)
            }
        }
    }
}

#Preview {
    SecondaryFieldSelection(passObject: .constant(MockModelData().passObjects[0]), disableControl: false)
}
