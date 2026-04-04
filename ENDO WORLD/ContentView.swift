import SwiftUI

struct ContentView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router
        ZStack(alignment: .bottom) {
            Color.bgPrimary.ignoresSafeArea()

            Group {
                switch router.selectedTab {
                case .today: TodayView()
                case .vitals: VitalsView()
                case .map: MapView()
                case .health: HealthView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            ENDOTabBar(selected: $router.selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    let appState = AppState()
    let router = AppRouter()
    router.onboardingComplete = true
    return ContentView()
        .environment(appState)
        .environment(router)
}
