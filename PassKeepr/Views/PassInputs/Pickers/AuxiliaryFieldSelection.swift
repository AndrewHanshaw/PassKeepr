import SwiftUI

struct AuxiliaryFieldSelection: View {
    @Binding var passObject: PassObject

    var disableControl: Bool

    @State private var shouldShowSecondAuxiliaryField: Bool = false // This state var, which shall always track the state of passObject.isAuxiliaryFieldOneOn, is necessary for the animation to work
    @State private var shouldShowThirdAuxiliaryField: Bool = false // This state var, which shall always track the state of passObject.isAuxiliaryFieldTwoOn, is necessary for the animation to work
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
        passObject.isCustomStripImageOn && totalCombinedFieldCount >= 4 && !(passObject.isAuxiliaryFieldOneOn && passObject.isAuxiliaryFieldTwoOn && passObject.isAuxiliaryFieldThreeOn)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 12) {
                Toggle("Auxiliary Field", isOn: $passObject.isAuxiliaryFieldOneOn)
                    .onChange(of: passObject.isAuxiliaryFieldOneOn) {
                        withAnimation {
                            shouldShowSecondAuxiliaryField = passObject.isAuxiliaryFieldOneOn && !isCapped
                            if !passObject.isAuxiliaryFieldOneOn {
                                passObject.isAuxiliaryFieldTwoOn = false
                            }
                        }
                    }
                    .padding([.top, .bottom], 14)
                    .overlay(alignment: .bottom) {
                        if shouldShowSecondAuxiliaryField {
                            Divider()
                        }
                    }
                    .padding([.leading, .trailing], 14)
                    .disabled(disableControl || (isCapped && !passObject.isAuxiliaryFieldOneOn))

                if shouldShowSecondAuxiliaryField {
                    Toggle("Additional Auxiliary Field", isOn: $passObject.isAuxiliaryFieldTwoOn)
                        .foregroundColor(isCapped && !passObject.isAuxiliaryFieldTwoOn ? .secondary : .primary)
                        .onChange(of: passObject.isAuxiliaryFieldTwoOn) {
                            withAnimation {
                                shouldShowThirdAuxiliaryField = passObject.isAuxiliaryFieldTwoOn && !isCapped
                                if !passObject.isAuxiliaryFieldTwoOn {
                                    passObject.isAuxiliaryFieldThreeOn = false
                                }
                            }
                        }
                        .padding(.bottom, 14)
                        .overlay(alignment: .bottom) {
                            if shouldShowThirdAuxiliaryField {
                                Divider()
                            }
                        }
                        .padding([.leading, .trailing], 14)
                        .disabled(disableControl || (isCapped && !passObject.isAuxiliaryFieldTwoOn))
                }

                if shouldShowThirdAuxiliaryField {
                    Toggle("Additional Auxiliary Field", isOn: $passObject.isAuxiliaryFieldThreeOn)
                        .foregroundColor(isCapped && !passObject.isAuxiliaryFieldThreeOn ? .secondary : .primary)
                        .transition(.opacity)
                        .padding([.bottom, .leading, .trailing], 14)
                        .disabled(disableControl || (isCapped && !passObject.isAuxiliaryFieldThreeOn))
                }
            }
            .listSectionBackgroundModifier()
            .onAppear {
                shouldShowCappedFootnote = isCapped
                if !isCapped {
                    shouldShowSecondAuxiliaryField = passObject.isAuxiliaryFieldOneOn
                    shouldShowThirdAuxiliaryField = passObject.isAuxiliaryFieldTwoOn
                } else {
                    shouldShowSecondAuxiliaryField = passObject.isAuxiliaryFieldTwoOn
                    shouldShowThirdAuxiliaryField = passObject.isAuxiliaryFieldThreeOn
                }
            }
            .onChange(of: isCapped) {
                withAnimation {
                    shouldShowCappedFootnote = isCapped
                    if !isCapped {
                        shouldShowSecondAuxiliaryField = passObject.isAuxiliaryFieldOneOn
                        shouldShowThirdAuxiliaryField = passObject.isAuxiliaryFieldTwoOn
                    } else {
                        shouldShowSecondAuxiliaryField = passObject.isAuxiliaryFieldTwoOn
                        shouldShowThirdAuxiliaryField = passObject.isAuxiliaryFieldThreeOn
                    }
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
    AuxiliaryFieldSelection(passObject: .constant(MockModelData().passObjects[0]), disableControl: false)
}
