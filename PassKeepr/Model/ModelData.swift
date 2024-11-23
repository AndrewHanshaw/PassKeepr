import Foundation

class ModelData: Sequence, ObservableObject {
    let filename: String = "PassKeeprData.json"

    @Published var passObjects: [PassObject] = [] // Holds all PassObjects in a single array

    var filteredPassObjects: [[PassObject]] = [] // Holds all PassObjects, each item of the array is a filtered array of PassObjects, filtered by passType

    init() {
        if let loadedData: [PassObject] = load(filename) {
            passObjects = loadedData
        }

        updateFilteredArray()
    }

    func makeIterator() -> some IteratorProtocol {
        passObjects.makeIterator()
    }

    func encodePassObjects() {
        encode(filename, passObjects)
        updateFilteredArray()
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

    func updateFilteredArray() {
        // Dictionary to hold PassObjects as they get sorted
        var filteredLists: [PassType: [PassObject]] = [:]

        // Iterate through each PassObject in the PassObjects array
        for item in passObjects {
            // Check if there's already an array associated with the current PassType
            if var temp = filteredLists[item.passType] {
                // If yes, append the current PassObject to the existing array
                temp.append(item)
                // Update the dictionary with the modified array
                filteredLists[item.passType] = temp
            } else {
                // If no array exists for the current PassType, create a new array with the current PassObject
                filteredLists[item.passType] = [item]
            }
        }

        // Convert the values of the dictionary (arrays of PassObjects) into an array of arrays
        filteredPassObjects = Array(filteredLists.values)
    }

    func deleteItemByID(_ idToDelete: UUID) {
        // Find the index of the item with the specified ID
        if let index = passObjects.firstIndex(where: { $0.id == idToDelete }) {
            // Remove the item from the list
            passObjects.remove(at: index)

            // Encode and save the updated data
            encodePassObjects()
        }
    }

    func deleteAllItems() {
        // Clear the PassObjects array
        passObjects.removeAll()

        // Encode and save the updated data
        encodePassObjects()
    }

    func deleteDataFile() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)

        do {
            // Check if the file exists before attempting to delete
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("Error deleting JSON file: \(error)")
        }
    }
}
