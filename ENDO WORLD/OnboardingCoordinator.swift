import SwiftUI

@Observable @MainActor
final class OnboardingFlow {
    var step: Int = 0
    var selectedConditions: Set<String> = []
    var enabledSignals: Set<String> = ["env", "bio", "move"]
}

struct OnboardingCoordinator: View {
    @Environment(AppState.self) private var appState
    @Environment(AppRouter.self) private var router
    @State private var flow = OnboardingFlow()

    var body: some View {
        ZStack {
            switch flow.step {
            case 0:
                WelcomeView(onContinue: advance)
            case 1:
                DemoCardView(
                    step: 0,
                    total: 2,
                    headline: "Your block, at a glance.",
                    bodyCopy: "Air quality, disease burden, care access — one composite score.",
                    onContinue: advance
                )
            case 2:
                DemoCardView(
                    step: 1,
                    total: 2,
                    headline: "See what your city is hiding.",
                    bodyCopy: "Every block has a health score. Every node tells a story.",
                    onContinue: advance
                )
            case 3:
                PermissionsView(onContinue: advance)
            case 4:
                ConditionView(selected: $flow.selectedConditions, onContinue: advance)
            case 5:
                SignalsView(enabled: $flow.enabledSignals) {
                    appState.selectedConditions = flow.selectedConditions
                    appState.enabledSignals = flow.enabledSignals
                    advance()
                }
            default:
                AllSetView {
                    router.onboardingComplete = true
                }
            }
        }
        .animation(.easeInOut(duration: 0.28), value: flow.step)
    }

    private func advance() {
        flow.step += 1
    }
}
