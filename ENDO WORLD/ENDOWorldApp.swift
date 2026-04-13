import SwiftUI

@main
struct ENDOWorldApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            AppTabRootView()
                .environment(appState)
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity)
                .ignoresSafeArea()
        }
    }
}

#Preview("Launch (same as MapRoot)") {
    AppTabRootView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
