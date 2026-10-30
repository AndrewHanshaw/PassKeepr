import PassKeeprCore
import SwiftUI

struct WifiQrCode: View {
    @Binding var passObject: PassObject

    var body: some View {
        VStack(spacing: 20) {
            LabeledContent {
                TextField("Network Name", text: $passObject.wifiSSID)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
            } label: {
                Text("SSID")
            }
            .padding(16)
            .listSectionBackgroundModifier()

            HStack {
                Text("Security")
                Spacer()
                Picker("Security", selection: $passObject.wifiSecurity) {
                    ForEach(WifiSecurity.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .accentColor(.secondary)
            }
            .padding(.vertical, 10)
            .padding(.trailing, 4)
            .padding(.leading, 12)
            .listSectionBackgroundModifier()

            if passObject.wifiSecurity != .none {
                LabeledContent {
                    SecureField("Password", text: $passObject.wifiPassword)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                } label: {
                    Text("Password")
                }
                .padding(16)
                .listSectionBackgroundModifier()
            }

            Toggle("Hidden Network", isOn: $passObject.wifiIsHidden)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .listSectionBackgroundModifier()
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            WifiQrCode(passObject: .constant(PassObject()))
        }
        .padding()
    }
}
