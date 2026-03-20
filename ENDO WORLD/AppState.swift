import Foundation
import SwiftUI
import CoreLocation

enum HealthArea: String, CaseIterable {
    case cardiovascular
    case environmental
    case sleep
    case stress
    case activity
    case neighborhood
}

struct ConditionEvent: Identifiable {
    let id = UUID()
    let time: Date
    let condition: String
    let severity: ZoneClassification
    let location: String
    let distance: String
}

struct ENDORoute: Identifiable {
    let id = UUID()
    let label: String
    let avgScore: Int
    let worstCondition: String
    let suggestedAlternative: String?
}

@Observable
@MainActor
final class AppState {

    var compositeScore: Int = 72
    var zoneClassification: ZoneClassification = .moderate
    var heartRate: Double = 72
    var hrv: Double = 42
    var spo2: Double = 98
    var noiseLevel: Double = 54
    var aqi: Int = 48
    var pm25: Double = 12.4
    var dominantSignal: String = "Air Quality"
    var userCoordinate: CLLocationCoordinate2D?
    var heatIndex: Double = 75

    var biometricLoadScore: Int { max(0, min(100, 100 - Int(heartRate - 60) - Int(40 - hrv / 2))) }
    var environmentalScore: Int { max(0, min(100, 100 - aqi / 2 - Int(pm25))) }
    var sleepScore: Int = 78
    var activityScore: Int = 71
    var stressScore: Int = 65

    var healthAreaScores: [HealthArea: Int] = [
        .cardiovascular: 75,
        .environmental: 72,
        .sleep: 78,
        .stress: 65,
        .activity: 71,
        .neighborhood: 82
    ]

    var conditionExposureHistory: [ConditionEvent] = []
    var routeHistory: [ENDORoute] = []
    var neighborhoodPinCount: Int = 7
}
