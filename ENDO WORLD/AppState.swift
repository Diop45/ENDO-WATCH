import Foundation
import SwiftUI

@Observable @MainActor
final class AppState {
    private static let mapIntroDismissedKey = "endo.mapIntro.dismissed"

    /// First-launch map control explainer; cleared after `acknowledgeMapIntro()`.
    var showMapIntro: Bool

    var zoneScore: Int = 74
    var zone: ZoneClassification = .moderate
    var aqi: Int = 38
    var pm25: Double = 12.4
    var noiseDB: Int = 54
    var heatF: Int = 78

    var biometricStream = BiometricStreamService()

    /// Heart rate (bpm) from live `BiometricStreamService` polling.
    var hr: Double {
        Double(biometricStream.currentHR)
    }

    /// HRV (ms) from live `BiometricStreamService` polling.
    var hrv: Double {
        biometricStream.currentHRV
    }

    /// SpO₂ (percent) from live `BiometricStreamService` polling.
    var spo2: Double {
        biometricStream.currentSpO2
    }

    /// Respiratory rate from Apple Health periodic refresh (not 5s stream).
    var rr: Double

    private let appleHealth = AppleHealthMetricsProvider()

    var atmosphericBackground: Color {
        if zone == .hostile {
            return Color(hex: "#1A0808")
        }
        if hrv < 25 {
            return Color(hex: "#180808")
        }
        if hr > 100 {
            return Color(hex: "#1A0A08")
        }
        return Color.bgPrimary
    }

    init() {
        showMapIntro = !UserDefaults.standard.bool(
            forKey: Self.mapIntroDismissedKey)
        let d = HealthSnapshot.defaults
        rr = d.respiratoryRatePerMin

        appleHealth.onSnapshot = { [weak self] snap in
            guard let self else { return }
            self.rr = snap.respiratoryRatePerMin
        }

        biometricStream.start()
    }

    /// Requests HealthKit read access for respiratory rate and refreshes RR.
    func startAppleHealthDataIntegration() async {
        let snap = HealthSnapshot(
            heartRateBpm: hr,
            heartRateVariabilityMs: hrv,
            oxygenSaturationPercent: spo2,
            respiratoryRatePerMin: rr)
        await appleHealth.requestAccessAndStartUpdates(
            initialSnapshot: snap)
    }

    /// Pulls the latest samples from HealthKit (e.g. after returning from Health or Settings).
    func refreshAppleHealthData() async {
        await appleHealth.refreshFromHealthKit()
    }

    func acknowledgeMapIntro() {
        UserDefaults.standard.set(
            true,
            forKey: Self.mapIntroDismissedKey)
        showMapIntro = false
    }
}
