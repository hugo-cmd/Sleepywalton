import Foundation

struct NFCTag: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var nickname: String
    var uid: String // NFC tag unique id as hex string
}