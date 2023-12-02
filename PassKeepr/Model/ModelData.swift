import Foundation

@Observable
class ModelData {
    var listItems: [ListItem] = []

    init() {
        let preLoadedListItems: [ListItem] = [ListItem(id: UUID(), passName: "ID Pass 1", passType: PassType.identificationPass, identificationNumber: 1234),
                                              ListItem(id: UUID(), passName: "Barcode Pass 1", passType: PassType.barcodePass, barcodeNumber: 1234)]

        if let loadedData: [ListItem] = load("data2.json") {
            listItems = loadedData
        } else {
            listItems = preLoadedListItems
            encode("data2.json", listItems)
        }
    }

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
        return try encoder.encode(data).write(to: file, options: .atomic)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }

}

func deleteItemByID(_ idToDelete: UUID, filename: String) {
    var loadedData: [ListItem] = load("data2.json")!

    // Find the index of the item with the specified ID
    if let index = loadedData.firstIndex(where: { $0.id == idToDelete }) {
        // Remove the item from the list
        loadedData.remove(at: index)

        // Encode and save the updated data
        encode("data2.json", loadedData)
    }
}

func deleteAllItems() {
    var loadedData: [ListItem] = load("data2.json")!
    // Clear the listItems array
    loadedData.removeAll()

    // Encode and save the updated data
    encode("data2.json", loadedData)
}

func deleteDataFile() {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = documentsDirectory.appendingPathComponent("data2.json")

    do {
        // Check if the file exists before attempting to delete
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    } catch {
        print("Error deleting data.json file: \(error)")
    }
}
