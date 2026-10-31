import Foundation

open class ModelData: ObservableObject {
    public struct PassKeeprData: Codable {
        public var passObjects: [PassObject]
        public var tutorialStage: Int

        public init(passObjects: [PassObject], tutorialStage: Int) {
            self.passObjects = passObjects
            self.tutorialStage = tutorialStage
        }
    }

    public let filename: String = "PassKeeprData.json"

    // Directory the data file lives in. Injectable so tests can use a temporary directory.
    public let directory: URL

    @Published open var passObjects: [PassObject] = [] // Holds all PassObjects in a single array
    @Published public var tutorialStage: Int = 0

    public init(directory: URL = URL.applicationSupportDirectory) {
        self.directory = directory
        if let loadedData: PassKeeprData = load(filename) {
            passObjects = loadedData.passObjects
            tutorialStage = loadedData.tutorialStage
        }
    }

    public func encodePassObjects() {
        let data = PassKeeprData(passObjects: passObjects, tutorialStage: tutorialStage)
        encode(filename, data)
    }

    private var pendingEncodeTask: Task<Void, Never>?

    // Debounced version of `encodePassObjects()` for hot paths that can change rapidly (e.g. every
    // keystroke or ColorPicker drag frame while editing a pass). Encoding + writing the whole passes
    // array (including all embedded image data) to disk is too expensive to do on every single change,
    // so rapid-fire calls each restart a short delay and only the last one actually writes to disk.
    public func scheduleEncodePassObjects(after delay: Duration = .milliseconds(400)) {
        pendingEncodeTask?.cancel()
        pendingEncodeTask = Task { [weak self] in
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }
            self?.encodePassObjects()
        }
    }

    // Cancels any pending debounced encode and writes immediately, so a scheduled save is never
    // lost if the caller goes away (e.g. a view disappearing) before the delay elapses.
    public func flushPendingEncode() {
        pendingEncodeTask?.cancel()
        pendingEncodeTask = nil
        encodePassObjects()
    }

    public func load<T: Decodable>(_ filename: String) -> T? {
        let file = directory.appendingPathComponent(filename)
        let data: Data

        do {
            data = try Data(contentsOf: file)
        } catch {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            return nil
        }
    }

    public func encode<T: Encodable>(_ filename: String, _ data: T) {
        let file = directory.appendingPathComponent(filename)

        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let encodedData = try encoder.encode(data)
            try encodedData.write(to: file, options: .atomic)
        } catch {
            print("Error encoding data: \(error)")
        }
    }

    public func deleteItemByID(_ idToDelete: UUID) {
        if let index = passObjects.firstIndex(where: { $0.id == idToDelete }) {
            passObjects.remove(at: index)

            encodePassObjects()
        }
    }

    public func deleteAllItems() {
        passObjects.removeAll()
        encodePassObjects()
    }

    public func deleteDataFile() {
        let fileURL = directory.appendingPathComponent(filename)

        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("Error deleting JSON file: \(error)")
        }
    }
}
