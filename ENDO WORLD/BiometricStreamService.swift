import Foundation
import HealthKit
import Observation
import SwiftUI

@Observable @MainActor
final class BiometricStreamService {

    var currentHR: Int = 72
    var currentHRV: Double = 45
    var currentSpO2: Double = 98
    /// True after at least one successful HealthKit sample read.
    private(set) var hasReadAccess: Bool = false
    var lastUpdate: Date = Date()

    private let store = HKHealthStore()
    private var setupTask: Task<Void, Never>?
    private var pollingTask: Task<Void, Never>?

    var hrDisplayString: String {
        hasReadAccess ? "\(currentHR)" : "—"
    }

    var hrvDisplayString: String {
        hasReadAccess
            ? String(format: "%.0f", currentHRV)
            : "—"
    }

    func start() {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        let types = Self.readTypes()
        guard !types.isEmpty else { return }
        if pollingTask != nil { return }

        setupTask?.cancel()
        setupTask = Task { @MainActor [weak self] in
            guard let self else { return }
            defer { self.setupTask = nil }
            do {
                try await store.requestAuthorization(
                    toShare: Set<HKSampleType>(),
                    read: types)
                guard !Task.isCancelled else { return }
                startPollingIfNeeded()
            } catch {
                hasReadAccess = false
            }
        }
    }

    func stop() {
        setupTask?.cancel()
        setupTask = nil
        pollingTask?.cancel()
        pollingTask = nil
    }

    private static func readTypes() -> Set<HKObjectType> {
        var set = Set<HKObjectType>()
        let ids: [HKQuantityTypeIdentifier] = [
            .heartRate,
            .heartRateVariabilitySDNN,
            .oxygenSaturation,
        ]
        for id in ids {
            if let t = HKQuantityType.quantityType(
                forIdentifier: id)
            {
                set.insert(t)
            }
        }
        return set
    }

    private func startPollingIfNeeded() {
        guard pollingTask == nil else { return }
        pollingTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                guard let self else { break }
                await self.fetchLatestReadings()
                try? await Task.sleep(
                    nanoseconds: 5_000_000_000)
            }
        }
    }

    private func fetchLatestReadings() async {
        async let hr = fetchLatestHR()
        async let hrv = fetchLatestHRV()
        async let spo2 = fetchLatestSpO2()

        let (hrVal, hrvVal, spo2Val) =
            await (hr, hrv, spo2)

        withAnimation(
            .easeInOut(duration: 0.4)
        ) {
            if let h = hrVal {
                currentHR = h
                hasReadAccess = true
            }
            if let v = hrvVal {
                currentHRV = v
                hasReadAccess = true
            }
            if let s = spo2Val {
                currentSpO2 = s
                hasReadAccess = true
            }
            lastUpdate = Date()
        }
    }

    private func fetchLatestHR() async -> Int? {
        guard let type = HKQuantityType.quantityType(
            forIdentifier: .heartRate)
        else { return nil }

        return await withCheckedContinuation { cont in
            let sort = NSSortDescriptor(
                key: HKSampleSortIdentifierEndDate,
                ascending: false)
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                let val = (samples?.first as? HKQuantitySample)?
                    .quantity
                    .doubleValue(
                        for: HKUnit.count()
                            .unitDivided(by: .minute()))
                cont.resume(returning: val.map { Int($0) })
            }
            store.execute(query)
        }
    }

    private func fetchLatestHRV() async -> Double? {
        guard let type = HKQuantityType.quantityType(
            forIdentifier:
                .heartRateVariabilitySDNN)
        else { return nil }

        return await withCheckedContinuation { cont in
            let sort = NSSortDescriptor(
                key: HKSampleSortIdentifierEndDate,
                ascending: false)
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                let val = (samples?.first as? HKQuantitySample)?
                    .quantity
                    .doubleValue(
                        for: HKUnit.secondUnit(
                            with: .milli))
                cont.resume(returning: val)
            }
            store.execute(query)
        }
    }

    private func fetchLatestSpO2() async -> Double? {
        guard let type = HKQuantityType.quantityType(
            forIdentifier: .oxygenSaturation)
        else { return nil }

        return await withCheckedContinuation { cont in
            let sort = NSSortDescriptor(
                key: HKSampleSortIdentifierEndDate,
                ascending: false)
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                guard let raw = (samples?.first as? HKQuantitySample)?
                    .quantity
                    .doubleValue(for: .percent())
                else {
                    cont.resume(returning: nil)
                    return
                }
                let pct = raw <= 1.0 && raw > 0
                    ? raw * 100
                    : raw
                cont.resume(
                    returning: pct > 0 ? pct : nil)
            }
            store.execute(query)
        }
    }
}
