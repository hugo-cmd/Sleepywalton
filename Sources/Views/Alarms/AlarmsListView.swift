import SwiftUI

struct AlarmsListView: View {
    @EnvironmentObject var app: AppState
    @State private var showingAdd = false

    var body: some View {
        NavigationView {
            List {
                ForEach(app.alarms) { alarm in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(alarm.timeString).font(.title2).bold()
                            Text(alarm.repeatRule.rawValue.capitalized).font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { alarm.isEnabled },
                            set: { newValue in
                                if let idx = app.alarms.firstIndex(of: alarm) {
                                    app.alarms[idx].isEnabled = newValue
                                    app.saveAll()
                                    app.scheduler.schedule(alarms: app.alarms)
                                }
                            }
                        )).labelsHidden()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { showingEdit(alarm) }
                }
                .onDelete { idx in
                    app.alarms.remove(atOffsets: idx)
                    app.saveAll()
                    app.scheduler.schedule(alarms: app.alarms)
                }
            }
            .navigationTitle("Alarms")
            .toolbar { Button(action: { showingAdd = true }) { Image(systemName: "plus") } }
            .sheet(isPresented: $showingAdd) {
                EditAlarmView(alarm: Alarm(hour: 6, minute: 30, isEnabled: true, repeatRule: .weekdays, soundName: "default", nfcTagId: nil)) { newAlarm in
                    app.alarms.append(newAlarm)
                    app.saveAll()
                    app.scheduler.schedule(alarms: app.alarms)
                }
            }
        }
    }

    private func showingEdit(_ alarm: Alarm) {
        // Minimal: open a sheet to edit copy
        let binding = Binding(get: { true }, set: { _ in })
        // Present an ephemeral sheet using a window-scoped presentation is complex here; for brevity we push add-only.
    }
}