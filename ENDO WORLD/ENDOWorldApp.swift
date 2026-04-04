import SwiftUI

@main
struct ENDOWorldApp: App {
    @State private var appState = AppState()
    @State private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            Group {
                if router.onboardingComplete {
                    ContentView()
                        .environment(appState)
                        .environment(router)
                } else {
                    OnboardingCoordinator()
                        .environment(appState)
                        .environment(router)
                }
            }
        }
    }
}
