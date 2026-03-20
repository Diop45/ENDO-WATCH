import Foundation

// MARK: - Input

struct FusionInput {
    var heartRate: Double        // bpm
    var hrv: Double              // ms SDNN
    var spo2: Double             // percentage 0–100
    var noiseLevel: Double       // dB
    var respiratoryRate: Double  // breaths/min
    var aqi: Int                 // EPA AQI
    var pm25: Double             // µg/m³
    var heatIndex: Double        // °F
    var resourceDensity: Double  // SAMHSA facility density 0–100
}

// MARK: - Output

struct FusionOutput {
    var zone: ZoneClassification
    var compositeScore: Int     // 0–100, higher = more supportive
    var dominantSignal: String  // name of the signal driving the zone
    var confidence: Double      // 0.0–1.0, fraction of non-zero inputs
}

// MARK: - Engine

struct ZoneFusionEngine {

    // Signal weights — must sum to 1.0
    private struct Weights {
        static let aqi:             Double = 0.20
        static let pm25:            Double = 0.15
        static let heatIndex:       Double = 0.10
        static let heartRate:       Double = 0.20
        static let hrv:             Double = 0.20
        static let noiseLevel:      Double = 0.10
        static let resourceDensity: Double = 0.05
    }

    func fuse(_ input: FusionInput) -> FusionOutput {
        let signals = computeSignals(input)
        let weightedSum = signals.values.reduce(0, +)
        let clamped = min(1.0, max(0.0, weightedSum))
        let score = Int((1.0 - clamped) * 100)
        let dominant = signals.max(by: { $0.value < $1.value })?.key ?? "Heart Rate"
        let nonZero = countNonZeroInputs(input)
        let confidence = Double(nonZero) / 7.0

        let zone: ZoneClassification
        switch score {
        case 66...100: zone = .supportive
        case 35...65:  zone = .moderate
        default:       zone = .hostile
        }

        return FusionOutput(
            zone: zone,
            compositeScore: score,
            dominantSignal: dominant,
            confidence: confidence
        )
    }

    // MARK: - Normalization

    private func computeSignals(_ i: FusionInput) -> [String: Double] {
        var signals: [String: Double] = [:]

        // AQI: 0 = good (0 stress), 500 = hazardous (1 stress)
        signals["Air Quality"] = Weights.aqi * min(Double(i.aqi) / 200.0, 1.0)

        // PM2.5: EPA 24-hr threshold 35.4 µg/m³ → 1.0 stress
        signals["PM2.5"] = Weights.pm25 * min(i.pm25 / 35.4, 1.0)

        // Heat Index: comfortable at 70°F, extreme at 130°F
        signals["Heat Index"] = Weights.heatIndex * min(max(i.heatIndex - 70.0, 0.0) / 60.0, 1.0)

        // Heart Rate: 60–100 normal. stress scales from 100→160
        signals["Heart Rate"] = Weights.heartRate * min(max(i.heartRate - 100.0, 0.0) / 60.0, 1.0)

        // HRV: higher = lower stress. 0 ms = max stress, 80 ms = no stress
        let hrvStress = i.hrv > 0 ? max(0.0, 1.0 - (i.hrv / 80.0)) : 0.5
        signals["HRV"] = Weights.hrv * min(hrvStress, 1.0)

        // Noise: below 40 dB silent (0 stress), above 90 dB damaging (1 stress)
        signals["Noise Level"] = Weights.noiseLevel * min(max(i.noiseLevel - 40.0, 0.0) / 50.0, 1.0)

        // Resource density: higher density = lower stress
        signals["Resource Density"] = Weights.resourceDensity * max(0.0, 1.0 - (i.resourceDensity / 100.0))

        return signals
    }

    private func countNonZeroInputs(_ i: FusionInput) -> Int {
        [i.heartRate, i.hrv, i.spo2, Double(i.aqi), i.pm25, i.heatIndex, i.resourceDensity]
            .filter { $0 > 0 }
            .count
    }
}
