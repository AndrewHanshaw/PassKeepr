import Foundation

@Observable
class ModelData {
    var listItems: [ListItem]

    init() {
        listItems = load("data.json")
    }

}

func load<T: Decodable>(_ filename: String) -> T {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let file = documentsDirectory.appendingPathComponent(filename)
    let data: Data

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
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
