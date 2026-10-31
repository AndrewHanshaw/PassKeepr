@testable import PassKeeprCore
import XCTest

final class WifiCodecTests: XCTestCase {
    func testFormatWifiProducesCorrectString() {
        let result = WifiCodec.formatWifi(
            ssid: "MyNetwork",
            security: .wpa,
            password: "hunter2",
            isHidden: false
        )
        XCTAssertEqual(result, "WIFI:T:WPA;S:MyNetwork;P:hunter2;H:false;;")
    }

    func testFormatWifiEscapesSpecialCharacters() {
        let result = WifiCodec.formatWifi(
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

        let result = WifiCodec.formatWifi(from: pass)
        XCTAssertTrue(result.hasPrefix("WIFI:"))
        XCTAssertTrue(result.contains("S:CoffeeShop"))
    }

    func testParseWifiRoundTrip() {
        let original = WifiCodec.formatWifi(
            ssid: "TestSSID",
            security: .wpa,
            password: "testpass",
            isHidden: false
        )
        let parsed = WifiCodec.parseWifi(original)
        XCTAssertEqual(parsed.ssid, "TestSSID")
        XCTAssertEqual(parsed.password, "testpass")
        XCTAssertEqual(parsed.security, .wpa)
        XCTAssertEqual(parsed.isHidden, false)
    }

    func testParseWifiRejectsNonWifiString() {
        let parsed = WifiCodec.parseWifi("not a wifi string")
        XCTAssertEqual(parsed.ssid, "")
    }
}
