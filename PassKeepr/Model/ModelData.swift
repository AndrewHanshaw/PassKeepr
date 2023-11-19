import Foundation

@Observable
class ModelData {
    var listItems: [ListItem]

    init() {
        let preLoadedListItems: [ListItem] = [ListItem(id: 3, name: "asdf1", type: passType.barcodePass), ListItem(id: 2, name: "asdf2", type: passType.identificationPass)]

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
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
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
