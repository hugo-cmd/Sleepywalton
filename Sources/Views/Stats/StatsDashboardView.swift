import SwiftUI

struct StatsDashboardView: View {
    @EnvironmentObject var app: AppState

    var avgSleep: String {
        let durations = app.logs.map { $0.durationSeconds }.filter { $0 > 0 }
        guard !durations.isEmpty else { return "--" }
        let avg = durations.reduce(0, +) / durations.count
        let h = avg / 3600
        let m = (avg % 3600) / 60
        return "\(h)h \(m)m"
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Average Sleep Duration").font(.headline)
                Text(avgSleep).font(.largeTitle).bold()
                List(app.logs) { log in
                    VStack(alignment: .leading) {
                        Text(DateFormatter.localizedString(from: log.date, dateStyle: .medium, timeStyle: .none))
                        Text("Wake: \(timeString(log.wakeTime))").font(.caption)
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Statistics")
        }
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}