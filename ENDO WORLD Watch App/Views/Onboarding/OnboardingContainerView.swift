import SwiftUI

// MARK: - OnboardingContainerView
// 11-step light onboarding. Transitions to HomeView (dark) on completion.

struct OnboardingContainerView: View {
    @State private var coordinator = OnboardingCoordinator()
    let onComplete: () -> Void

    var body: some View {
        Group {
            if coordinator.isComplete {
                Color.clear
            } else {
                stepContent
            }
        }
        .onChange(of: coordinator.isComplete) { _, complete in
            if complete {
                onComplete()
            }
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        Group {
            switch coordinator.currentStep {
        case .step1:
            OnboardingStep1View(coordinator: coordinator)
        case .step2:
            OnboardingStep2View(coordinator: coordinator)
        case .step3:
            OnboardingStep3View(coordinator: coordinator)
        case .step4:
            OnboardingStep4View(coordinator: coordinator)
        case .step5:
            OnboardingStep5View(coordinator: coordinator)
        case .step6:
            OnboardingStep6View(coordinator: coordinator)
        case .step7:
            OnboardingStep7View(coordinator: coordinator)
        case .step8:
            OnboardingStep8View(coordinator: coordinator)
        case .step9:
            OnboardingStep9View(coordinator: coordinator)
        case .step10:
            OnboardingStep10View(coordinator: coordinator)
        case .step11:
            OnboardingStep11View(coordinator: coordinator)
        }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
        .animation(.easeInOut(duration: 0.35), value: coordinator.currentStep)
    }
}
