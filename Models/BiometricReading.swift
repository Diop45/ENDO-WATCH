import Foundation

enum BiometricSource: String, Codable {
    case appleWatch
    case ouraRing
    case manual
}

struct BiometricReading: Codable {
    var heartRate: Double       // bpm
    var hrv: Double             // ms (SDNN)
    var spo2: Double            // percentage (e.g. 98.0)
    var respiratoryRate: Double // breaths/min
    var timestamp: Date
    var source: BiometricSource

    static let mock = BiometricReading(
        heartRate: 68,
        hrv: 42,
        spo2: 98,
        respiratoryRate: 14,
        timestamp: .now,
        source: .appleWatch
    )
}
