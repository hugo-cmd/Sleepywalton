import SwiftUI

@main
struct SleepyWaltonApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .onAppear {
                    appState.bootstrap()
                }
        }
    }
}