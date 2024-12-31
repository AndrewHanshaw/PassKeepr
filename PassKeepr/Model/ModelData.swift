import Foundation

class ModelData: Sequence, ObservableObject {
    let filename: String = "PassKeeprData.json"

    @Published var passObjects: [PassObject] = [] // Holds all PassObjects in a single array

    init() {
        if let loadedData: [PassObject] = load(filename) {
            passObjects = loadedData
        }
    }

    func makeIterator() -> some IteratorProtocol {
        passObjects.makeIterator()
    }

    func encodePassObjects() {
        encode(filename, passObjects)
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
            return try encoder.encode(data).write(to: file, options: .atomic)
        } catch {
            return
                //        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
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
