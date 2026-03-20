import Foundation
import HealthKit

@Observable
class WatchHealthKitService {
    var latestReading: BiometricReading = .mock
    var isAuthorized: Bool = false

    private let healthStore = HKHealthStore()

    private let readTypes: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
        HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
        HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.workoutType()
    ]

    // MARK: - Authorization

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            isAuthorized = true
            await fetchLatestBiometrics()
        } catch {
            isAuthorized = false
        }
    }

    // MARK: - Fetch

    func fetchLatestBiometrics() async {
        async let hr   = fetchLatest(.heartRate,               unit: HKUnit(from: "count/min"))
        async let hrv  = fetchLatest(.heartRateVariabilitySDNN, unit: .secondUnit(with: .milli))
        async let spo2 = fetchLatest(.oxygenSaturation,        unit: .percent())
        async let resp = fetchLatest(.respiratoryRate,          unit: HKUnit(from: "count/min"))

        let (heartRate, hrVariability, oxygenSaturation, respiratoryRate) = await (hr, hrv, spo2, resp)

        latestReading = BiometricReading(
            heartRate:      heartRate ?? 68,
            hrv:            hrVariability ?? 42,
            spo2:           (oxygenSaturation ?? 0.98) * 100,
            respiratoryRate: respiratoryRate ?? 14,
            timestamp:      .now,
            source:         .appleWatch
        )
    }

    // MARK: - Private

    private func fetchLatest(_ identifier: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double? {
        guard let type = HKObjectType.quantityType(forIdentifier: identifier) else { return nil }
        let predicate = HKQuery.predicateForSamples(
            withStart: Date().addingTimeInterval(-3600),
            end: .now
        )
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: sample.quantity.doubleValue(for: unit))
            }
            healthStore.execute(query)
        }
    }
}
