@testable import PassKeepr
import XCTest

final class WifiQrCodeTests: XCTestCase {
    func testFormatWifiProducesCorrectString() {
        let result = WifiQrCode.formatWifi(
            ssid: "MyNetwork",
            security: .wpa,
            password: "hunter2",
            isHidden: false
        )
        XCTAssertEqual(result, "WIFI:T:WPA;S:MyNetwork;P:hunter2;H:false;;")
    }

    func testFormatWifiEscapesSpecialCharacters() {
        let result = WifiQrCode.formatWifi(
            ssid: "My;Network",
            security: .wpa,
            password: "p;a:s;s",
            isHidden: true
        )
        XCTAssertTrue(result.contains("S:My\\;Network"))
        XCTAssertTrue(result.contains("H:true"))
    }

    func testFormatWifiFromPassObject() {
        var pass = PassObject()
        pass.wifiSSID = "CoffeeShop"
        pass.wifiSecurity = .none
        pass.wifiPassword = ""
        pass.wifiIsHidden = false

        let result = WifiQrCode.formatWifi(from: pass)
        XCTAssertTrue(result.hasPrefix("WIFI:"))
        XCTAssertTrue(result.contains("S:CoffeeShop"))
    }

    func testParseWifiRoundTrip() {
        let original = WifiQrCode.formatWifi(
            ssid: "TestSSID",
            security: .wpa,
            password: "testpass",
            isHidden: false
        )
        let parsed = WifiQrCode.parseWifi(original)
        XCTAssertEqual(parsed.ssid, "TestSSID")
        XCTAssertEqual(parsed.password, "testpass")
        XCTAssertEqual(parsed.security, .wpa)
        XCTAssertEqual(parsed.isHidden, false)
    }

    func testParseWifiRejectsNonWifiString() {
        let parsed = WifiQrCode.parseWifi("not a wifi string")
        XCTAssertEqual(parsed.ssid, "")
    }
}
