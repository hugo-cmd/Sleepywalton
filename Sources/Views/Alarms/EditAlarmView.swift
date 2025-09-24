import SwiftUI

struct EditAlarmView: View {
    @Environment(\.dismiss) private var dismiss

    @State var alarm: Alarm
    var onSave: (Alarm) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Time")) {
                    DatePicker("Time", selection: Binding(get: {
                        Calendar.current.date(from: DateComponents(hour: alarm.hour, minute: alarm.minute)) ?? Date()
                    }, set: { date in
                        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
                        alarm.hour = comps.hour ?? 6
                        alarm.minute = comps.minute ?? 30
                    }), displayedComponents: [.hourAndMinute])
                }
                Picker("Repeat", selection: $alarm.repeatRule) {
                    ForEach(RepeatRule.allCases, id: \.self) { rule in
                        Text(rule.rawValue.capitalized).tag(rule)
                    }
                }
                Toggle("Enabled", isOn: $alarm.isEnabled)
            }
            .navigationTitle("Add Alarm")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave(alarm); dismiss() }
                }
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
    }
}