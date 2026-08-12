import Foundation

// Formats a raw value as a localized currency string using the given ISO 4217 currency code.
// Falls back to the original text if formatting fails.
func formattedCurrencyText(_ text: String, currencyCode: String) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currencyCode

    guard let formatted = formatter.string(from: NSNumber(value: currencyFieldValue(text))) else {
        return text
    }
    return formatted
}
