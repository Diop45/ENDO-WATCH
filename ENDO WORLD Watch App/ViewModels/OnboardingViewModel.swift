import Foundation
import SwiftUI
import CoreLocation
import HealthKit
import UserNotifications
import ObjectiveC

// MARK: - OnboardingViewModel

@MainActor
@Observable
final class OnboardingViewModel {

    enum Step: String, CaseIterable {
        case globe
        case welcome
        case whyItMatters
        case locationPerm
        case healthPerm
        case notifPerm
        case privacyPledge
        case allSet
    }

    var step: Step = .globe
    var locationGranted = false
    var healthGranted = false
    var notifGranted = false
    var locationRequested = false
    var healthRequested = false
    var notifRequested = false
    var shareConsent = false
    var isComplete = false

    func advance() {
        guard let idx = Step.allCases.firstIndex(of: step),
              idx + 1 < Step.allCases.count else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
            step = Step.allCases[idx + 1]
        }
    }

    func requestLocation() async {
        let manager = CLLocationManager()
        let granted = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            let delegate = LocationAuthDelegate(continuation: cont)
            manager.delegate = delegate
            objc_setAssociatedObject(manager, &LocationAuthDelegate.key, delegate, .OBJC_ASSOCIATION_RETAIN)
            manager.requestWhenInUseAuthorization()
            // Fallback: if status already determined, delegate may not fire
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                if delegate.continuation != nil {
                    let status = manager.authorizationStatus
                    delegate.continuation = nil
                    cont.resume(returning: status == .authorizedWhenInUse || status == .authorizedAlways)
                }
            }
        }
        locationGranted = granted
        locationRequested = true
        if granted {
            try? await Task.sleep(nanoseconds: 800_000_000)
            advance()
        }
    }

    func requestHealth() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            healthGranted = false
            try? await Task.sleep(nanoseconds: 800_000_000)
            advance()
            return
        }
        let store = HKHealthStore()
        var readTypes = Set<HKObjectType>()
        for id in [HKQuantityTypeIdentifier.heartRate, .heartRateVariabilitySDNN, .oxygenSaturation,
                   .respiratoryRate, .vo2Max, .environmentalAudioExposure] {
            if let t = HKQuantityType.quantityType(forIdentifier: id) {
                readTypes.insert(t)
            }
        }
        let success = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            store.requestAuthorization(toShare: [], read: readTypes) { success, _ in
                cont.resume(returning: success)
            }
        }
        healthGranted = success
        healthRequested = true
        if success {
            try? await Task.sleep(nanoseconds: 800_000_000)
            advance()
        }
    }

    func requestNotifications() async {
        do {
            notifGranted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            notifGranted = false
        }
        notifRequested = true
        if notifGranted {
            try? await Task.sleep(nanoseconds: 800_000_000)
            advance()
        }
    }

    func finish() {
        UserDefaults.standard.set(true, forKey: "endo.onboardingComplete")
        if shareConsent {
            UserDefaults.standard.set(true, forKey: "endo.shareConsent")
        }
        isComplete = true
    }
}

// MARK: - Location delegate (retained by CLLocationManager via associated object)

private final class LocationAuthDelegate: NSObject, CLLocationManagerDelegate {
    static var key: UInt8 = 0
    nonisolated(unsafe) var continuation: CheckedContinuation<Bool, Never>?

    init(continuation: CheckedContinuation<Bool, Never>) {
        self.continuation = continuation
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let granted = manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways
        if let cont = continuation {
            continuation = nil
            cont.resume(returning: granted)
        }
    }
}
