import Foundation

public enum WifiCodec {
    public static func formatWifi(from passObject: PassObject) -> String {
        formatWifi(
            ssid: passObject.wifiSSID,
            security: passObject.wifiSecurity,
            password: passObject.wifiPassword,
            isHidden: passObject.wifiIsHidden
        )
    }

    static func formatWifi(ssid: String, security: WifiSecurity, password: String, isHidden: Bool) -> String {
        "WIFI:T:\(security.rawValue);S:\(escapeWifi(ssid));P:\(escapeWifi(password));H:\(isHidden);;"
    }

    public static func parseWifi(_ string: String) -> (ssid: String, password: String, security: WifiSecurity, isHidden: Bool) {
        guard string.uppercased().hasPrefix("WIFI:") else {
            return ("", "", .wpa, false)
        }
        var ssid = ""
        var password = ""
        var security: WifiSecurity = .wpa
        var isHidden = false
        let content = String(string.dropFirst(5))
        for part in content.components(separatedBy: ";") {
            if part.hasPrefix("S:") {
                ssid = unescapeWifi(String(part.dropFirst(2)))
            } else if part.hasPrefix("P:") {
                password = unescapeWifi(String(part.dropFirst(2)))
            } else if part.hasPrefix("T:") {
                security = WifiSecurity(rawValue: String(part.dropFirst(2))) ?? .wpa
            } else if part.hasPrefix("H:") {
                isHidden = String(part.dropFirst(2)).lowercased() == "true"
            }
        }
        return (ssid, password, security, isHidden)
    }

    private static func escapeWifi(_ s: String) -> String {
        s
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: ";", with: "\\;")
            .replacingOccurrences(of: ",", with: "\\,")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }

    private static func unescapeWifi(_ s: String) -> String {
        var result = ""
        var iter = s.makeIterator()
        while let ch = iter.next() {
            if ch == "\\" {
                if let next = iter.next() {
                    switch next {
                    case "\\": result.append("\\")
                    case ";": result.append(";")
                    case ",": result.append(",")
                    case "\"": result.append("\"")
                    default: result.append(next)
                    }
                }
            } else {
                result.append(ch)
            }
        }
        return result
    }
}
