import Foundation
import HealthKit

@Observable
class HealthKitService {

    private let healthStore = HKHealthStore()

    private let readTypes: Set<HKObjectType> = {
        var types = Set<HKObjectType>()
        let identifiers: [HKQuantityTypeIdentifier] = [
            .heartRate,
            .heartRateVariabilitySDNN,
            .oxygenSaturation,
            .respiratoryRate,
            .vo2Max,
            .stepCount,
            .activeEnergyBurned,
            .environmentalAudioExposure
        ]
        for id in identifiers {
            if let type = HKObjectType.quantityType(forIdentifier: id) {
                types.insert(type)
            }
        }
        types.insert(HKWorkoutType.workoutType())
        return types
    }()

    init() {
        Task { await requestAuthorization() }
    }

    // MARK: - Authorization

    private func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        try? await healthStore.requestAuthorization(toShare: [], read: readTypes)
    }

    // MARK: - Latest values

    func fetchLatestHeartRate() async -> Double {
        await fetchLatest(.heartRate, unit: HKUnit(from: "count/min"))
    }

    func fetchLatestHRV() async -> Double {
        await fetchLatest(.heartRateVariabilitySDNN, unit: .secondUnit(with: .milli))
    }

    func fetchLatestVO2Max() async -> Double {
        let unit = HKUnit.literUnit(with: .milli)
            .unitDivided(by: HKUnit.gramUnit(with: .kilo))
            .unitDivided(by: HKUnit.minute())
        return await fetchLatest(.vo2Max, unit: unit)
    }

    func fetchLatestSpO2() async -> Double {
        let fraction = await fetchLatest(.oxygenSaturation, unit: .percent())
        return fraction * 100
    }

    func fetchLatestNoiseLevel() async -> Double {
        await fetchLatest(.environmentalAudioExposure, unit: .decibelAWeightedSoundPressureLevel())
    }

    // MARK: - History

    func fetchHeartRateHistory(hours: Int) async -> [Double] {
        await fetchHistory(.heartRate, unit: HKUnit(from: "count/min"), hours: hours)
    }

    func fetchHRVHistory(hours: Int) async -> [Double] {
        await fetchHistory(.heartRateVariabilitySDNN, unit: .secondUnit(with: .milli), hours: hours)
    }

    // MARK: - Observer

    func observeHeartRate(onChange: @escaping () -> Void) {
        guard let type = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        let query = HKObserverQuery(sampleType: type, predicate: nil) { _, completionHandler, error in
            defer { completionHandler() }
            guard error == nil else { return }
            onChange()
        }
        healthStore.execute(query)
    }

    // MARK: - Private helpers

    private func fetchLatest(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double {
        guard let type = HKObjectType.quantityType(forIdentifier: id) else { return 0.0 }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: 0.0)
                    return
                }
                continuation.resume(returning: sample.quantity.doubleValue(for: unit))
            }
            healthStore.execute(query)
        }
    }

    private func fetchHistory(_ id: HKQuantityTypeIdentifier, unit: HKUnit, hours: Int) async -> [Double] {
        guard let type = HKObjectType.quantityType(forIdentifier: id) else { return [] }
        let limit = hours * 6
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: limit,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                guard let samples = samples as? [HKQuantitySample] else {
                    continuation.resume(returning: [])
                    return
                }
                let values = samples
                    .sorted { $0.startDate < $1.startDate }
                    .map { $0.quantity.doubleValue(for: unit) }
                continuation.resume(returning: values)
            }
            healthStore.execute(query)
        }
    }
}
