@testable import PassKeeprCore
import XCTest

final class PersistenceTests: XCTestCase {
    private var directory: URL!

    override func setUpWithError() throws {
        // Not created up front, so tests also cover ModelData creating missing directories
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathComponent("AppSupport", isDirectory: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory.deletingLastPathComponent())
    }

    private func makePass(_ description: String, barcode: String, type: BarcodeType) -> PassObject {
        var pass = PassObject()
        pass.description = description
        pass.barcodeString = barcode
        pass.barcodeType = type
        return pass
    }

    private var dataFile: URL {
        directory.appendingPathComponent("PassKeeprData.json")
    }

    func testPassKeeprDataRoundTrip() throws {
        let original = ModelData.PassKeeprData(
            passObjects: [
                makePass("Gym Membership", barcode: "GYM12345", type: .code128),
                makePass("Library Card", barcode: "LIB98765", type: .qr),
            ],
            tutorialStage: 3
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ModelData.PassKeeprData.self, from: data)

        XCTAssertEqual(decoded.passObjects.count, 2)
        XCTAssertEqual(decoded.passObjects[0].description, "Gym Membership")
        XCTAssertEqual(decoded.passObjects[0].barcodeString, "GYM12345")
        XCTAssertEqual(decoded.passObjects[1].description, "Library Card")
        XCTAssertEqual(decoded.tutorialStage, 3)
    }

    func testEmptyPassListRoundTrip() throws {
        let original = ModelData.PassKeeprData(passObjects: [], tutorialStage: 0)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ModelData.PassKeeprData.self, from: data)
        XCTAssertTrue(decoded.passObjects.isEmpty)
    }

    func testStartsEmptyWhenNoFileExists() {
        let model = ModelData(directory: directory)
        XCTAssertTrue(model.passObjects.isEmpty)
        XCTAssertEqual(model.tutorialStage, 0)
    }

    func testSavedDataIsLoadedByNewInstance() {
        let model = ModelData(directory: directory)
        let pass = makePass("Gym Membership", barcode: "GYM12345", type: .code128)
        model.passObjects = [pass]
        model.tutorialStage = 4
        model.encodePassObjects()

        let reloaded = ModelData(directory: directory)
        XCTAssertEqual(reloaded.passObjects, [pass])
        XCTAssertEqual(reloaded.tutorialStage, 4)
    }

    func testEncodeCreatesMissingDirectory() {
        XCTAssertFalse(FileManager.default.fileExists(atPath: directory.path))

        ModelData(directory: directory).encodePassObjects()

        XCTAssertTrue(FileManager.default.fileExists(atPath: dataFile.path))
    }

    func testCorruptFileLoadsAsEmpty() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try Data("not json".utf8).write(to: dataFile)

        let model = ModelData(directory: directory)

        XCTAssertTrue(model.passObjects.isEmpty)
        XCTAssertEqual(model.tutorialStage, 0)
    }

    func testDeleteItemByIDRemovesOnlyThatPassAndPersists() {
        let model = ModelData(directory: directory)
        let keep = makePass("Keep", barcode: "1", type: .qr)
        let remove = makePass("Remove", barcode: "2", type: .qr)
        model.passObjects = [keep, remove]
        model.encodePassObjects()

        model.deleteItemByID(remove.id)

        XCTAssertEqual(model.passObjects, [keep])
        XCTAssertEqual(ModelData(directory: directory).passObjects, [keep])
    }

    func testDeleteItemByIDWithUnknownIDChangesNothing() {
        let model = ModelData(directory: directory)
        let pass = makePass("Keep", barcode: "1", type: .qr)
        model.passObjects = [pass]

        model.deleteItemByID(UUID())

        XCTAssertEqual(model.passObjects, [pass])
    }

    func testDeleteAllItemsPersists() {
        let model = ModelData(directory: directory)
        model.passObjects = [makePass("A", barcode: "1", type: .qr), makePass("B", barcode: "2", type: .qr)]
        model.encodePassObjects()

        model.deleteAllItems()

        XCTAssertTrue(model.passObjects.isEmpty)
        XCTAssertTrue(ModelData(directory: directory).passObjects.isEmpty)
    }

    func testDeleteDataFileRemovesFileAndIsSafeWhenMissing() {
        let model = ModelData(directory: directory)
        model.deleteDataFile() // no file yet, must not fail

        model.encodePassObjects()
        XCTAssertTrue(FileManager.default.fileExists(atPath: dataFile.path))

        model.deleteDataFile()
        XCTAssertFalse(FileManager.default.fileExists(atPath: dataFile.path))
    }

    func testFlushPendingEncodeWritesImmediately() {
        let model = ModelData(directory: directory)
        let pass = makePass("Pending", barcode: "1", type: .qr)
        model.passObjects = [pass]
        model.scheduleEncodePassObjects(after: .seconds(60))
        XCTAssertFalse(FileManager.default.fileExists(atPath: dataFile.path))

        model.flushPendingEncode()

        XCTAssertEqual(ModelData(directory: directory).passObjects, [pass])
    }

    func testScheduledEncodeIsDebouncedToLastChange() async throws {
        let model = ModelData(directory: directory)
        model.passObjects = [makePass("First", barcode: "1", type: .qr)]
        model.scheduleEncodePassObjects(after: .milliseconds(100))
        let last = makePass("Last", barcode: "2", type: .qr)
        model.passObjects = [last]
        model.scheduleEncodePassObjects(after: .milliseconds(100))

        try await Task.sleep(for: .milliseconds(600))

        XCTAssertEqual(ModelData(directory: directory).passObjects, [last])
    }
}
