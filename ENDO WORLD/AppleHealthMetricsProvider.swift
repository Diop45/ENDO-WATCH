import Foundation
import HealthKit

/// Reads heart rate, HRV (SDNN), blood oxygen, and respiratory rate from HealthKit.
@MainActor
final class AppleHealthMetricsProvider {

    private let store = HKHealthStore()

    /// Called on the main actor when samples are read.
    var onSnapshot: ((HealthSnapshot) -> Void)?

    private(set) var isHealthDataAvailable: Bool

    private var lastDelivered: HealthSnapshot

    init() {
        isHealthDataAvailable = HKHealthStore.isHealthDataAvailable()
        lastDelivered = .defaults
    }

    func requestAccessAndStartUpdates(
        initialSnapshot: HealthSnapshot
    ) async {
        lastDelivered = initialSnapshot
        guard isHealthDataAvailable else {
            onSnapshot?(lastDelivered)
            return
        }

        let readTypes = Self.quantityTypesToRead()
        guard !readTypes.isEmpty else {
            onSnapshot?(lastDelivered)
            return
        }

        let typesToShare: Set<HKSampleType> = []

        do {
            try await store.requestAuthorization(
                toShare: typesToShare,
                read: readTypes)
        } catch {
            onSnapshot?(lastDelivered)
            return
        }

        let merged = await fetchSnapshot(
            mergingInto: lastDelivered)
        lastDelivered = merged
        onSnapshot?(merged)
    }

    func refreshFromHealthKit() async {
        guard isHealthDataAvailable else { return }
        let merged = await fetchSnapshot(
            mergingInto: lastDelivered)
        lastDelivered = merged
        onSnapshot?(merged)
    }

    private static func quantityTypesToRead() -> Set<HKObjectType> {
        var set = Set<HKObjectType>()
        let ids: [HKQuantityTypeIdentifier] = [
            .heartRate,
            .heartRateVariabilitySDNN,
            .oxygenSaturation,
            .respiratoryRate,
        ]
        for id in ids {
            if let t = HKQuantityType.quantityType(forIdentifier: id) {
                set.insert(t)
            }
        }
        return set
    }

    private func fetchSnapshot(
        mergingInto baseline: HealthSnapshot
    ) async -> HealthSnapshot {
        var snap = baseline
        let start = Calendar.current.date(
            byAdding: .day,
            value: -90,
            to: Date()) ?? Date.distantPast
        let predicate = HKQuery.predicateForSamples(
            withStart: start,
            end: Date(),
            options: .strictEndDate)
        let sort = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false)

        if let type = HKQuantityType.quantityType(
            forIdentifier: .heartRate),
           let sample = await latestQuantitySample(
            type: type,
            predicate: predicate,
            sort: sort)
        {
            let v = sample.quantity.doubleValue(
                for: HKUnit.count()
                    .unitDivided(by: .minute()))
            if v > 0 { snap.heartRateBpm = v }
        }

        if let type = HKQuantityType.quantityType(
            forIdentifier: .heartRateVariabilitySDNN),
           let sample = await latestQuantitySample(
            type: type,
            predicate: predicate,
            sort: sort)
        {
            let v = sample.quantity.doubleValue(
                for: HKUnit.secondUnit(with: .milli))
            if v > 0 { snap.heartRateVariabilityMs = v }
        }

        if let type = HKQuantityType.quantityType(
            forIdentifier: .oxygenSaturation),
           let sample = await latestQuantitySample(
            type: type,
            predicate: predicate,
            sort: sort)
        {
            let percent = HKUnit.percent()
            let raw = sample.quantity.doubleValue(for: percent)
            let normalized: Double
            if raw <= 1.0, raw > 0 {
                normalized = raw * 100
            } else {
                normalized = raw
            }
            if normalized > 0 {
                snap.oxygenSaturationPercent = normalized
            }
        }

        if let type = HKQuantityType.quantityType(
            forIdentifier: .respiratoryRate),
           let sample = await latestQuantitySample(
            type: type,
            predicate: predicate,
            sort: sort)
        {
            let v = sample.quantity.doubleValue(
                for: HKUnit.count()
                    .unitDivided(by: .minute()))
            if v > 0 { snap.respiratoryRatePerMin = v }
        }

        return snap
    }

    private func latestQuantitySample(
        type: HKQuantityType,
        predicate: NSPredicate,
        sort: NSSortDescriptor
    ) async -> HKQuantitySample? {
        await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                continuation.resume(
                    returning: samples?.first as? HKQuantitySample)
            }
            store.execute(query)
        }
    }
}
