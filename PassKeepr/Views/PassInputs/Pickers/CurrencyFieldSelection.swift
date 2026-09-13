import SwiftUI

struct CurrencyFieldSelection: View {
    @Binding var passObject: PassObject

    var disableControl: Bool

    @State private var showCurrencyFields: Bool = false

    private static let currencyCodes: [String] = Locale.commonISOCurrencyCodes.sorted()

    private func currencyDisplayName(for code: String) -> String {
        if let name = Locale.current.localizedString(forCurrencyCode: code) {
            return "\(code) - \(name)"
        }
        return code
    }

    private struct FieldToggleRow: Identifiable {
        let id: String
        let genericName: String
        let userLabel: String
        let binding: Binding<Bool>
    }

    private var fieldRows: [FieldToggleRow] {
        var rows: [FieldToggleRow] = [
            FieldToggleRow(
                id: "primary",
                genericName: "Primary Field",
                userLabel: passObject.primaryFieldLabel,
                binding: $passObject.isPrimaryFieldCurrency
            ),
            FieldToggleRow(
                id: "header1",
                genericName: "Header Field",
                userLabel: passObject.headerFieldOneLabel,
                binding: $passObject.isHeaderFieldOneCurrency
            ),
        ]

        if passObject.isHeaderFieldTwoOn {
            rows.append(FieldToggleRow(
                id: "header2",
                genericName: "Additional Header Field",
                userLabel: passObject.headerFieldTwoLabel,
                binding: $passObject.isHeaderFieldTwoCurrency
            ))
        }

        rows.append(FieldToggleRow(
            id: "secondary1",
            genericName: "Secondary Field",
            userLabel: passObject.secondaryFieldOneLabel,
            binding: $passObject.isSecondaryFieldOneCurrency
        ))

        if passObject.isSecondaryFieldTwoOn {
            rows.append(FieldToggleRow(
                id: "secondary2",
                genericName: "Additional Secondary Field",
                userLabel: passObject.secondaryFieldTwoLabel,
                binding: $passObject.isSecondaryFieldTwoCurrency
            ))
        }

        if passObject.isSecondaryFieldThreeOn {
            rows.append(FieldToggleRow(
                id: "secondary3",
                genericName: "Additional Secondary Field",
                userLabel: passObject.secondaryFieldThreeLabel,
                binding: $passObject.isSecondaryFieldThreeCurrency
            ))
        }

        if passObject.isAuxiliaryFieldOneOn {
            rows.append(FieldToggleRow(
                id: "auxiliary1",
                genericName: "Auxiliary Field",
                userLabel: passObject.auxiliaryFieldOneLabel,
                binding: $passObject.isAuxiliaryFieldOneCurrency
            ))
        }

        if passObject.isAuxiliaryFieldTwoOn {
            rows.append(FieldToggleRow(
                id: "auxiliary2",
                genericName: "Additional Auxiliary Field",
                userLabel: passObject.auxiliaryFieldTwoLabel,
                binding: $passObject.isAuxiliaryFieldTwoCurrency
            ))
        }

        if passObject.isAuxiliaryFieldThreeOn {
            rows.append(FieldToggleRow(
                id: "auxiliary3",
                genericName: "Additional Auxiliary Field",
                userLabel: passObject.auxiliaryFieldThreeLabel,
                binding: $passObject.isAuxiliaryFieldThreeCurrency
            ))
        }

        return rows
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Toggle("Currency Fields", isOn: $passObject.isCurrencyFieldsOn)
                .onChange(of: passObject.isCurrencyFieldsOn) {
                    withAnimation {
                        showCurrencyFields = passObject.isCurrencyFieldsOn
                    }
                }
                .padding(.vertical, 14)
                .overlay(alignment: .bottom) {
                    if showCurrencyFields {
                        Divider()
                    }
                }
                .padding(.horizontal, 14)
                .disabled(disableControl)

            if showCurrencyFields {
                HStack {
                    Text("Currency Code")
                    Spacer()
                    Picker("Currency Code", selection: $passObject.currencyCode) {
                        ForEach(Self.currencyCodes, id: \.self) { code in
                            Text(currencyDisplayName(for: code)).tag(code)
                        }
                    }
                    .disabled(disableControl)
                    .accentColor(.secondary)
                }
                .padding(.vertical, 10)
                .padding(.trailing, 4)
                .padding(.leading, 14)
                .overlay(alignment: .bottom) {
                    Divider()
                }
                .transition(.opacity)

                ForEach(Array(fieldRows.enumerated()), id: \.element.id) { index, row in
                    CurrencyFieldRow(genericName: row.genericName, userLabel: row.userLabel, isSelected: row.binding)
                        .overlay(alignment: .bottom) {
                            if index != fieldRows.count - 1 {
                                Divider()
                            }
                        }
                        .disabled(disableControl)
                        .transition(.opacity)
                }
            }
        }
        .listSectionBackgroundModifier()
        .onAppear {
            showCurrencyFields = passObject.isCurrencyFieldsOn
        }
    }
}

#Preview {
    CurrencyFieldSelection(passObject: .constant(MockModelData().passObjects[0]), disableControl: false)
}

/// A tappable list row that shows a trailing checkmark when selected, in place of a Toggle switch —
/// matching the multi-select checklist style used throughout iOS Settings (e.g. Sounds, Tags).
private struct CurrencyFieldRow: View {
    let genericName: String
    let userLabel: String
    @Binding var isSelected: Bool

    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(genericName)
                        .foregroundStyle(.primary)
                    if !userLabel.isEmpty {
                        Text("\"\(userLabel)\"")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
                    .opacity(isSelected ? 1 : 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
    }
}
