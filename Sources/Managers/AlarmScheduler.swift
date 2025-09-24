import Foundation
import UserNotifications
import Combine

final class AlarmScheduler: NSObject, UNUserNotificationCenterDelegate {
    let ringRequests = PassthroughSubject<Void, Never>()

    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        center.delegate = self
    }

    func schedule(alarms: [Alarm]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        for alarm in alarms where alarm.isEnabled {
            let content = UNMutableNotificationContent()
            content.title = "Alarm"
            content.body = "Wake up"
            content.sound = .defaultCriticalSound(withAudioVolume: 1.0)
            content.categoryIdentifier = "ALARM_CATEGORY"

            var date = DateComponents()
            date.hour = alarm.hour
            date.minute = alarm.minute

            let repeats: Bool
            switch alarm.repeatRule {
            case .once: repeats = false
            case .daily, .weekdays, .weekends: repeats = true
            }

            if alarm.repeatRule == .weekdays || alarm.repeatRule == .weekends {
                let weekdays = Set(2...6)
                for weekday in 1...7 {
                    let isWeekday = weekdays.contains(weekday)
                    let include = (alarm.repeatRule == .weekdays && isWeekday) || (alarm.repeatRule == .weekends && (weekday == 1 || weekday == 7))
                    if include {
                        var d = date
                        d.weekday = weekday
                        let trigger = UNCalendarNotificationTrigger(dateMatching: d, repeats: true)
                        let id = "alarm-\(alarm.id.uuidString)-\(weekday)"
                        let req = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                        center.add(req)
                    }
                }
            } else {
                let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: repeats)
                let req = UNNotificationRequest(identifier: "alarm-\(alarm.id.uuidString)", content: content, trigger: trigger)
                center.add(req)
            }
        }
    }

    // MARK: UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        ringRequests.send(())
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}