import Foundation

/// Latest biometric values read from Apple Health (HealthKit).
struct HealthSnapshot: Equatable {
    var heartRateBpm: Double
    var heartRateVariabilityMs: Double
    var oxygenSaturationPercent: Double
    var respiratoryRatePerMin: Double

    static let defaults = HealthSnapshot(
        heartRateBpm: 72,
        heartRateVariabilityMs: 48,
        oxygenSaturationPercent: 97,
        respiratoryRatePerMin: 14)
}
