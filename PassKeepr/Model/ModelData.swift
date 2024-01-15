import Foundation

@Observable
class ModelData: Sequence {
    let preview: Bool

    let filename: String = "PassKeeprData.json"

    var listItems: [ListItem] = [] // Holds all listItems in a single array

    var filteredListItems: [[ListItem]] = [] // Holds all listItems, each item of the array is a filtered array of ListItems, filtered by passType

    let preLoadedListItems: [ListItem] = [ListItem(id: UUID(), passName: "ID Pass 1", passType: PassType.identificationPass, identificationString: "1234"),
                                          ListItem(id: UUID(), passName: "Barcode Pass 1", passType: PassType.barcodePass, barcodeString: "1234")]

    init(preview: Bool) {
        self.preview = preview


        if(self.preview == true)
        {
            encode(filename, preLoadedListItems)
        }
        if let loadedData: [ListItem] = load(filename) {
            listItems = loadedData
        } else {
            listItems = preLoadedListItems
            encode(filename, listItems)
        }

        updateFilteredArray()
    }

    func makeIterator() -> some IteratorProtocol {
        return listItems.makeIterator()
    }

    func encodeListItems() {
        encode(filename, listItems)
        updateFilteredArray()
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
        return
//        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }

}

func updateFilteredArray() {
    // Dictionary to hold ListItems as they get sorted
    var filteredLists: [PassType: [ListItem]] = [:]

    // Iterate through each ListItem in the listItems array
    for item in listItems {
        // Check if there's already an array associated with the current PassType
        if var temp = filteredLists[item.passType] {
            // If yes, append the current ListItem to the existing array
            temp.append(item)
            // Update the dictionary with the modified array
            filteredLists[item.passType] = temp
        } else {
            // If no array exists for the current PassType, create a new array with the current ListItem
            filteredLists[item.passType] = [item]
        }
    }
    // Convert the values of the dictionary (arrays of ListItems) into an array of arrays
    filteredListItems = Array(filteredLists.values)
}

func deleteItemByID(_ idToDelete: UUID, filename: String) {
    var loadedData: [ListItem] = load(filename)!

    // Find the index of the item with the specified ID
    if let index = loadedData.firstIndex(where: { $0.id == idToDelete }) {
        // Remove the item from the list
        loadedData.remove(at: index)

        // Encode and save the updated data
        encode(filename, loadedData)
    }
}

func deleteAllItems(filename: String) {
    var loadedData: [ListItem] = load(filename)!
    // Clear the listItems array
    loadedData.removeAll()

    let preLoadedListItems: [ListItem] = [ListItem(id: UUID(), passName: "ID Pass 1", passType: PassType.identificationPass, identificationNumber: "1234"),
                                          ListItem(id: UUID(), passName: "Barcode Pass 1", passType: PassType.barcodePass, barcodeString: "1234")]

    // Encode and save the updated data
    encode(filename, preLoadedListItems)
}

func deleteDataFile(filename: String) {
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
