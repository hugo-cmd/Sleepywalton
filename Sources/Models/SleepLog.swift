import Foundation

struct SleepLog: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date
    var bedtime: Date?
    var wakeTime: Date
    var dismissalLatencySeconds: Int

    var durationSeconds: Int {
        guard let bed = bedtime else { return 0 }
        return Int(wakeTime.timeIntervalSince(bed))
    }
}