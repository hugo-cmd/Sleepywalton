import SwiftUI

struct AlarmRingView: View {
    let scheduledTime: Date
    var onDismissed: () -> Void

    @EnvironmentObject var app: AppState

    var body: some View {
        VStack(spacing: 24) {
            Text(timeString(scheduledTime)).font(.system(size: 72, weight: .bold, design: .rounded))
            Button("Scan NFC to dismiss") {
                app.nfc.scanOnce()
            }
            .buttonStyle(.borderedProminent)
            Button("Emergency Unlock") {
                Task {
                    if await app.security.authenticate(reason: "Dismiss alarm") {
                        onDismissed()
                    }
                }
            }
        }
        .padding()
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm"
        return f.string(from: date)
    }
}