import CoreLocation
import Foundation
import SwiftUI

@Observable @MainActor
final class AppState {
    var zoneScore: Int = 74
    var zone: ZoneClassification = .supportive
    var dominantSignal: String = "Air Quality"
    var aqi: Int = 38
    var pm25: Double = 12.4
    var noiseDB: Int = 54
    var heatF: Int = 78

    var hr: Double = 72
    var hrv: Double = 48
    var spo2: Double = 97
    var rr: Double = 14

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

    var selectedConditions: Set<String> = []
    var enabledSignals: Set<String> = ["env", "bio", "move"]
    var scanStreak: Int = 5
    var totalXP: Int = 340

    var mapEntryPoint: MapEntryPoint = .normal

    enum MapEntryPoint {
        case normal, proximityAlert
    }

    var peekNode: HealthNode?
}
