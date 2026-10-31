@testable import PassKeepr
import Vision
import XCTest

final class BarcodeTypeMappingTests: XCTestCase {
    func testQRMapsToQR() {
        XCTAssertEqual(VNBarcodeSymbology.qr.toBarcodeType(), .qr)
    }

    func testCode128MapsToCode128() {
        XCTAssertEqual(VNBarcodeSymbology.code128.toBarcodeType(), .code128)
    }

    func testCode39MapsToCode39() {
        XCTAssertEqual(VNBarcodeSymbology.code39.toBarcodeType(), .code39)
    }

    func testCode93MapsToCode93() {
        XCTAssertEqual(VNBarcodeSymbology.code93.toBarcodeType(), .code93)
    }

    func testEAN13MapsToEAN13() {
        XCTAssertEqual(VNBarcodeSymbology.ean13.toBarcodeType(), .ean13)
    }

    func testUPCEMapsToUPCE() {
        XCTAssertEqual(VNBarcodeSymbology.upce.toBarcodeType(), .upce)
    }

    func testUnsupportedSymbologyReturnsNil() {
        XCTAssertNil(VNBarcodeSymbology.aztec.toBarcodeType())
        XCTAssertNil(VNBarcodeSymbology.pdf417.toBarcodeType())
    }
}
