import SwiftUI
import HealthKit

// MARK: - View Model

@Observable
@MainActor
class ENDOWatchViewModel {

    // MARK: - Biometric state

    var heartRate: Double = 0
    var hrv: Double = 0
    var vo2Max: Double = 0
    var spo2: Double = 0
    var noiseLevel: Double = 0
    var heartRateHistory: [Double] = []
    var hrvHistory: [Double] = []

    // MARK: - Zone state

    var zoneClassification: ZoneClassification = .moderate
    var compositeScore: Int = 0
    var zoneScoreHistory: [Int] = []

    // MARK: - Environmental state

    var locationLabel: String = "Detroit, MI"
    var aqi: Int = 0
    var pm25: Double = 0

    // MARK: - Dependencies

    private let healthKitService = HealthKitService()

    // MARK: - Load

    func load() async {
        async let hrTask        = healthKitService.fetchLatestHeartRate()
        async let hrvTask       = healthKitService.fetchLatestHRV()
        async let vo2Task       = healthKitService.fetchLatestVO2Max()
        async let spo2Task      = healthKitService.fetchLatestSpO2()
        async let noiseTask     = healthKitService.fetchLatestNoiseLevel()
        async let hrHistTask    = healthKitService.fetchHeartRateHistory(hours: 2)
        async let hrvHistTask   = healthKitService.fetchHRVHistory(hours: 2)

        let (hr, hrvVal, vo2, sp, noise, hrHist, hrvHist) = await (
            hrTask, hrvTask, vo2Task, spo2Task, noiseTask, hrHistTask, hrvHistTask
        )

        heartRate        = hr
        hrv              = hrvVal
        vo2Max           = vo2
        spo2             = sp
        noiseLevel       = noise
        heartRateHistory = hrHist
        hrvHistory       = hrvHist

        computeZoneClassification()
    }

    // MARK: - Passive updates

    nonisolated func startPassiveUpdates() {
        let service = healthKitService
        service.observeHeartRate {
            Task.detached { [weak self] in
                await self?.load()
            }
        }
    }

    // MARK: - Private

    private func computeZoneClassification() {
        let hrScore: Double = {
            if heartRate > 100 { return min((heartRate - 100) / 40.0, 1.0) }
            return 0.0
        }()

        let hrvScore: Double = {
            if hrv <= 0 { return 0.5 }
            return max(0.0, 1.0 - (hrv / 80.0))
        }()

        let aqiScore: Double = {
            if aqi > 100 { return 1.0 }
            if aqi < 50  { return 0.0 }
            return Double(aqi - 50) / 50.0
        }()

        let rawScore = (hrScore * 0.25) + (hrvScore * 0.35) + (aqiScore * 0.40)
        let stressScore = min(1.0, max(0.0, rawScore))
        compositeScore = Int((1.0 - stressScore) * 100)

        switch compositeScore {
        case 66...100: zoneClassification = .supportive
        case 35...65:  zoneClassification = .moderate
        default:       zoneClassification = .hostile
        }

        zoneScoreHistory = (0..<23).map { _ in
            min(100, max(0, compositeScore + Int.random(in: -10...10)))
        } + [compositeScore]
    }
}
