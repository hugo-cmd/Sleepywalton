import SwiftUI

struct OnboardingView: View {
    var onFinish: () -> Void
    @EnvironmentObject var app: AppState

    @State private var step: Int = 0
    @State private var pin: String = ""
    @State private var nickname: String = "Kitchen"

    var body: some View {
        VStack(spacing: 24) {
            if step == 0 { welcome }
            if step == 1 { pinStep }
            if step == 2 { nfcStep }
        }
        .padding()
    }

    private var welcome: some View {
        VStack(spacing: 16) {
            Text("Welcome to SleepyWalton").font(.largeTitle).bold()
            Text("We’ll send you notifications for alarms.")
            Button("Allow Notifications") {
                app.scheduler.requestAuthorization()
                step = 1
            }.buttonStyle(.borderedProminent)
        }
    }

    private var pinStep: some View {
        VStack(spacing: 16) {
            Text("Secure Fallback").font(.title2).bold()
            SecureField("Create a 4-digit PIN", text: $pin)
                .keyboardType(.numberPad)
            Button("Save PIN") { app.security.savePIN(pin); step = 2 }
                .buttonStyle(.borderedProminent)
        }
    }

    private var nfcStep: some View {
        VStack(spacing: 16) {
            Text("Register your first NFC tag").font(.title2).bold()
            TextField("Nickname", text: $nickname).textFieldStyle(.roundedBorder)
            Button("Add NFC Chip") {
                let uid = UUID().uuidString.prefix(8)
                app.tags.append(NFCTag(nickname: nickname, uid: String(uid)))
                app.saveAll()
                onFinish()
            }.buttonStyle(.borderedProminent)
            Button("Skip for now") { onFinish() }
        }
    }
}