import Foundation

class ModelData: ObservableObject {
    struct PassKeeprData: Codable {
        var passObjects: [PassObject]
        var tutorialStage: Int
    }

    let filename: String = "PassKeeprData.json"

    @Published var passObjects: [PassObject] = [] // Holds all PassObjects in a single array
    @Published var tutorialStage: Int = 0

    init() {
        if let loadedData: PassKeeprData = load(filename) {
            passObjects = loadedData.passObjects
            tutorialStage = loadedData.tutorialStage
        }
    }

    func encodePassObjects() {
        let data = PassKeeprData(passObjects: passObjects, tutorialStage: tutorialStage)
        encode(filename, data)
    }

    func load<T: Decodable>(_ filename: String) -> T? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let file = documentsDirectory.appendingPathComponent(filename)
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

    func encode<T: Encodable>(_ filename: String, _ data: T) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let file = documentsDirectory.appendingPathComponent(filename)

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let encodedData = try encoder.encode(data)
            try encodedData.write(to: file, options: .atomic)
        } catch {
            print("Error encoding data: \(error)")
        }
    }

    func deleteItemByID(_ idToDelete: UUID) {
        if let index = passObjects.firstIndex(where: { $0.id == idToDelete }) {
            passObjects.remove(at: index)

            encodePassObjects()
        }
    }

    func deleteAllItems() {
        passObjects.removeAll()
        encodePassObjects()
    }

    func deleteDataFile() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)

        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("Error deleting JSON file: \(error)")
        }
    }
}
