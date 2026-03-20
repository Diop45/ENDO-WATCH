import Foundation
import SwiftUI

// MARK: - OnboardingStep

enum OnboardingStep: Int, CaseIterable {
    case step1 = 1   // What is public health
    case step2 = 2   // The awareness gap
    case step3 = 3   // What ENDO does
    case step4 = 4   // Location permission
    case step5 = 5   // Health permission
    case step6 = 6   // Profile (age + sex)
    case step7 = 7   // Condition selection
    case step8 = 8   // Signal selection
    case step9 = 9   // Data privacy
    case step10 = 10 // Notification permission
    case step11 = 11 // All set

    var stepIndex: Int { rawValue - 1 }
}

// MARK: - HealthCondition

enum HealthCondition: String, CaseIterable {
    case asthma = "Asthma"
    case copd = "COPD"
    case heartDisease = "Heart Disease"
    case hypertension = "Hypertension"
    case diabetes = "Diabetes"
    case anxiety = "Anxiety"
    case migraine = "Migraine"
    case allergies = "Allergies"
    case sleepApnea = "Sleep Apnea"

    var icon: String {
        switch self {
        case .asthma, .copd: return "lungs.fill"
        case .heartDisease, .hypertension: return "heart.fill"
        case .diabetes: return "drop.fill"
        case .anxiety, .migraine: return "brain.head.profile"
        case .allergies: return "allergens"
        case .sleepApnea: return "bed.double.fill"
        }
    }
}

// MARK: - SexOption

enum SexOption: String, CaseIterable {
    case male = "Male"
    case female = "Female"
    case nonBinary = "Non-binary"
    case preferNotToSay = "Prefer not to say"
}

// MARK: - SignalCategory

enum SignalCategory: String, CaseIterable {
    case biometric = "Biometric"
    case environmental = "Environmental"
    case movement = "Movement"
    case urbanStress = "Urban Stress"
    case healthPatterns = "Health Patterns"

    var count: Int {
        switch self {
        case .biometric: return 9
        case .environmental: return 7
        case .movement: return 7
        case .urbanStress: return 2
        case .healthPatterns: return 3
        }
    }

    var dotColor: Color {
        switch self {
        case .biometric: return Color(hex: "#0D1B2A")
        case .environmental: return Color(hex: "#00B4D8")
        case .movement: return Color(hex: "#34C759")
        case .urbanStress: return Color(hex: "#FFB800")
        case .healthPatterns: return Color(hex: "#BF5AF2")
        }
    }

    var displayName: String {
        self == .healthPatterns ? "Patterns" : rawValue
    }
}

// MARK: - OnboardingProfile

@Observable
@MainActor
final class OnboardingProfile {
    var age: Int = 0
    var ageDouble: Double = 25
    var biologicalSex: String = "—"
    var sex: SexOption? {
        get { SexOption(rawValue: biologicalSex) }
        set { biologicalSex = newValue?.rawValue ?? "—" }
    }
    var selectedConditions: Set<HealthCondition> = []
    var signalCategoriesEnabled: Set<SignalCategory> = Set(SignalCategory.allCases)
    var anonymousDataOptIn: Bool = false
    var hasRespondedToDataPrompt: Bool = false
    var shareAnonymously: Bool? {
        get { hasRespondedToDataPrompt ? anonymousDataOptIn : nil }
        set {
            if let v = newValue {
                anonymousDataOptIn = v
                hasRespondedToDataPrompt = true
            }
        }
    }
    var zoneAlertsEnabled = true
    var airQualityAlertsEnabled = true
    var biometricAlertsEnabled = true

    var selectedSignalsCount: Int {
        signalCategoriesEnabled.reduce(0) { $0 + $1.count }
    }

    func toggle(_ condition: HealthCondition) {
        if selectedConditions.contains(condition) {
            selectedConditions.remove(condition)
        } else {
            selectedConditions.insert(condition)
        }
    }

    func save() {
        if age > 0 {
            UserDefaults.standard.set(age, forKey: "endo.profileAge")
        }
        if biologicalSex != "—" {
            UserDefaults.standard.set(biologicalSex, forKey: "endo.profileSex")
        }
        let conditions = selectedConditions.map { $0.rawValue }
        UserDefaults.standard.set(conditions, forKey: "endo.selectedConditions")
        let categories = signalCategoriesEnabled.map { $0.rawValue }
        UserDefaults.standard.set(categories, forKey: "endo.signalCategories")
        UserDefaults.standard.set(anonymousDataOptIn, forKey: "endo.shareConsent")
        UserDefaults.standard.set(zoneAlertsEnabled, forKey: "endo.zoneAlerts")
        UserDefaults.standard.set(airQualityAlertsEnabled, forKey: "endo.airQualityAlerts")
        UserDefaults.standard.set(biometricAlertsEnabled, forKey: "endo.biometricAlerts")
    }
}

// MARK: - OnboardingCoordinator

@Observable
@MainActor
final class OnboardingCoordinator {
    var currentStep: OnboardingStep = .step1
    var isComplete = false
    var profile = OnboardingProfile()

    var stepIndex: Int { currentStep.stepIndex }

    func advance() {
        guard let next = OnboardingStep(rawValue: currentStep.rawValue + 1) else { return }
        withAnimation(.easeInOut(duration: 0.35)) {
            currentStep = next
        }
    }

    func back() {
        guard currentStep.rawValue > 1,
              let prev = OnboardingStep(rawValue: currentStep.rawValue - 1) else { return }
        withAnimation(.easeInOut(duration: 0.35)) {
            currentStep = prev
        }
    }

    func finish() {
        profile.save()
        UserDefaults.standard.set(true, forKey: "endo.onboardingComplete")
        withAnimation(.easeInOut(duration: 0.35)) {
            isComplete = true
        }
    }
}
