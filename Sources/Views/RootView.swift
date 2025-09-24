import SwiftUI

struct RootView: View {
    @EnvironmentObject var app: AppState
    @AppStorage("didCompleteOnboarding") private var didOnboard: Bool = false

    var body: some View {
        Group {
            if didOnboard {
                TabView {
                    AlarmsListView()
                        .tabItem { Label("Alarms", systemImage: "alarm") }
                    StatsDashboardView()
                        .tabItem { Label("Stats", systemImage: "chart.bar") }
                    NFCManagementView()
                        .tabItem { Label("NFC", systemImage: "dot.radiowaves.left.and.right") }
                    SettingsView()
                        .tabItem { Label("Settings", systemImage: "gearshape") }
                }
            } else {
                OnboardingView(onFinish: { didOnboard = true })
            }
        }
        .sheet(isPresented: $app.isRinging) {
            AlarmRingView(scheduledTime: Date(), onDismissed: { app.dismissRing() })
                .environmentObject(app)
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var app: AppState
    @State private var pin: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Security")) {
                    SecureField("Set PIN", text: $pin)
                    Button("Save PIN") {
                        app.security.savePIN(pin)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}