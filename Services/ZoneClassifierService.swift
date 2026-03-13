import Foundation

struct ZoneClassifierService {

    func classifyZone(biometric: BiometricReading, environmental: EnvironmentalReading) -> ZoneClassification {
        let envStress  = computeEnvironmentalStress(environmental)
        let bioStress  = computeBiometricStress(biometric)
        let composite  = (envStress * 0.6) + (bioStress * 0.4)

        switch composite {
        case 0.0..<0.35:  return .supportive
        case 0.35..<0.65: return .moderate
        default:          return .hostile
        }
    }

    // MARK: - Environmental (60% weight)

    private func computeEnvironmentalStress(_ r: EnvironmentalReading) -> Double {
        // AQI: 0–50 good, 51–100 moderate, 101+ unhealthy
        let aqiScore   = min(Double(r.aqi) / 200.0, 1.0)
        // PM2.5: EPA annual standard 12 µg/m³; 35.4 = 24-hr unhealthy threshold
        let pm25Score  = min(r.pm25 / 35.4, 1.0)
        // Noise: hazardous above 70 dB sustained; scale from 40 dB floor
        let noiseScore = min(max(r.noiseLevel - 40.0, 0.0) / 50.0, 1.0)
        // Heat: caution starts at 80°F; extreme at 130°F
        let heatScore  = min(max(r.heatIndex - 70.0, 0.0) / 60.0, 1.0)

        return (aqiScore * 0.40) + (pm25Score * 0.30) + (noiseScore * 0.20) + (heatScore * 0.10)
    }

    // MARK: - Biometric (40% weight)

    private func computeBiometricStress(_ r: BiometricReading) -> Double {
        // HR: resting 60–100 bpm; elevated resting HR correlates with autonomic stress
        let hrScore   = min(max(r.heartRate - 60.0, 0.0) / 60.0, 1.0)
        // HRV: higher = better recovery; <20 ms = high stress, >60 ms = optimal
        let hrvScore  = max(1.0 - (r.hrv / 60.0), 0.0)
        // SpO2: <95% = hypoxia; 100% = perfect
        let spo2Score = max(1.0 - ((r.spo2 - 90.0) / 10.0), 0.0)
        // Respiratory: 12–20 normal; >20 = physiological stress
        let respScore = min(max(r.respiratoryRate - 12.0, 0.0) / 20.0, 1.0)

        return (hrScore * 0.30) + (hrvScore * 0.40) + (spo2Score * 0.20) + (respScore * 0.10)
    }
}
