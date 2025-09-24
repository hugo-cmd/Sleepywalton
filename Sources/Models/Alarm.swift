import Foundation

struct Alarm: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var hour: Int
    var minute: Int
    var isEnabled: Bool
    var repeatRule: RepeatRule
    var soundName: String
    var nfcTagId: UUID?
}

enum RepeatRule: String, Codable, CaseIterable {
    case once
    case daily
    case weekdays
    case weekends
}

extension Alarm {
    var timeString: String {
        let dateComponents = DateComponents(hour: hour, minute: minute)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}