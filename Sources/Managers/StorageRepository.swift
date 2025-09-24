import Foundation

final class StorageRepository {
    enum FileKey: String { case alarms, tags, sleepLogs }

    func url(for key: FileKey) throws -> URL {
        let dir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return dir.appendingPathComponent("\(key.rawValue).json")
    }

    func save<T: Encodable>(_ value: T, to key: FileKey) throws {
        let data = try JSONEncoder().encode(value)
        try data.write(to: try url(for: key), options: [.atomic])
    }

    func load<T: Decodable>(_ type: T.Type, from key: FileKey) throws -> T {
        let data = try Data(contentsOf: try url(for: key))
        return try JSONDecoder().decode(T.self, from: data)
    }
}