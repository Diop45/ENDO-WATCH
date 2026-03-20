import SwiftUI

@main
struct ENDOWatchApp: App {
    init() {
        // Reset onboarding for testing — remove these lines after testing
        UserDefaults.standard.removeObject(forKey: "endo.onboardingComplete")
        UserDefaults.standard.removeObject(forKey: "endo.earthZoomShown")
    }

    @State private var onboardingDone =
        UserDefaults.standard.bool(forKey: "endo.onboardingComplete")
    @State private var earthZoomShown =
        UserDefaults.standard.bool(forKey: "endo.earthZoomShown")

    var body: some Scene {
        WindowGroup {
            if !onboardingDone {
                OnboardingContainerView(onComplete: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        onboardingDone = true
                    }
                })
            } else if !earthZoomShown {
                EarthZoomTransitionView(onComplete: {
                    UserDefaults.standard.set(true, forKey: "endo.earthZoomShown")
                    withAnimation(.easeOut(duration: 0.3)) {
                        earthZoomShown = true
                    }
                })
                .transition(.opacity.animation(.easeOut(duration: 0.3)))
            } else {
                HomeView()
                    .transition(.opacity.animation(.easeOut(duration: 0.3)))
            }
        }
    }
}
