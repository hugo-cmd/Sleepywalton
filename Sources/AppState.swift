import Foundation
import Combine

final class AppState: ObservableObject {
    @Published var alarms: [Alarm] = []
    @Published var tags: [NFCTag] = []
    @Published var logs: [SleepLog] = []

    @Published var isRinging: Bool = false
    @Published var currentRingDate: Date? = nil

    let storage = StorageRepository()
    let scheduler = AlarmScheduler()
    let security = SecurityManager()
    let nfc = NFCManager()

    private var cancellables: Set<AnyCancellable> = []

    func bootstrap() {
        alarms = (try? storage.load([Alarm].self, from: .alarms)) ?? []
        tags = (try? storage.load([NFCTag].self, from: .tags)) ?? []
        logs = (try? storage.load([SleepLog].self, from: .sleepLogs)) ?? []
        scheduler.requestAuthorization()

        scheduler.ringRequests
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.presentRing()
            }
            .store(in: &cancellables)
    }

    func presentRing() {
        currentRingDate = Date()
        isRinging = true
    }

    func dismissRing(successViaNFC: Bool = false) {
        guard let ringDate = currentRingDate else { isRinging = false; return }
        let latency = Int(Date().timeIntervalSince(ringDate))
        let log = SleepLog(date: Date(), bedtime: nil, wakeTime: Date(), dismissalLatencySeconds: latency)
        logs.insert(log, at: 0)
        saveAll()
        isRinging = false
    }

    func saveAll() {
        try? storage.save(alarms, to: .alarms)
        try? storage.save(tags, to: .tags)
        try? storage.save(logs, to: .sleepLogs)
    }
}