import Foundation
import HealthKit

// MARK: - BiometricStreamService
// Provides continuous live biometric readings via HKAnchoredObjectQuery.
// Use this for the map pipeline. HealthKitService (single-shot) continues
// to serve the dashboard's one-time load.

@Observable
@MainActor
class BiometricStreamService {

    var heartRate: Double      = 0
    var hrv: Double            = 0
    var spo2: Double           = 0
    var noiseLevel: Double     = 0
    var respiratoryRate: Double = 0
    var lastUpdated: Date      = .now

    private let healthStore = HKHealthStore()
    private var activeQueries: [HKQuery] = []
    private var anchors: [HKQuantityTypeIdentifier: HKQueryAnchor] = [:]

    private let readTypes: [(HKQuantityTypeIdentifier, HKUnit)] = [
        (.heartRate,                   HKUnit(from: "count/min")),
        (.heartRateVariabilitySDNN,    .secondUnit(with: .milli)),
        (.oxygenSaturation,            .percent()),
        (.environmentalAudioExposure,  .decibelAWeightedSoundPressureLevel()),
        (.respiratoryRate,             HKUnit(from: "count/min"))
    ]

    // MARK: - Lifecycle

    func startStreaming() {
        Task { await requestAuthorizationAndBegin() }
    }

    func stopStreaming() {
        activeQueries.forEach { healthStore.stop($0) }
        activeQueries.removeAll()
    }

    // MARK: - Authorization

    private func requestAuthorizationAndBegin() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let types = Set(readTypes.compactMap { HKObjectType.quantityType(forIdentifier: $0.0) })
        do {
            try await healthStore.requestAuthorization(toShare: [], read: types)
            beginAnchoredQueries()
        } catch {
            // Authorization denied — stream will remain at defaults
        }
    }

    // MARK: - Anchored Queries

    private func beginAnchoredQueries() {
        for (identifier, unit) in readTypes {
            guard let type = HKObjectType.quantityType(forIdentifier: identifier) else { continue }
            startAnchoredQuery(for: type, identifier: identifier, unit: unit)
        }
    }

    private func startAnchoredQuery(
        for type: HKQuantityType,
        identifier: HKQuantityTypeIdentifier,
        unit: HKUnit
    ) {
        let anchor = anchors[identifier]
        let query = HKAnchoredObjectQuery(
            type: type,
            predicate: nil,
            anchor: anchor,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, newAnchor, _ in
            self?.handleSamples(samples, identifier: identifier, unit: unit, newAnchor: newAnchor)
        }

        query.updateHandler = { [weak self] _, samples, _, newAnchor, _ in
            self?.handleSamples(samples, identifier: identifier, unit: unit, newAnchor: newAnchor)
        }

        healthStore.execute(query)
        activeQueries.append(query)
    }

    // MARK: - Sample handling

    private func handleSamples(
        _ samples: [HKSample]?,
        identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        newAnchor: HKQueryAnchor?
    ) {
        guard let sample = (samples as? [HKQuantitySample])?.last else { return }
        var value = sample.quantity.doubleValue(for: unit)

        // oxygenSaturation is a fraction — convert to percentage
        if identifier == .oxygenSaturation { value *= 100 }

        Task { @MainActor [weak self] in
            guard let self else { return }
            if let anchor = newAnchor { self.anchors[identifier] = anchor }
            switch identifier {
            case .heartRate:                   self.heartRate       = value
            case .heartRateVariabilitySDNN:    self.hrv             = value
            case .oxygenSaturation:            self.spo2            = value
            case .environmentalAudioExposure:  self.noiseLevel      = value
            case .respiratoryRate:             self.respiratoryRate = value
            default: break
            }
            self.lastUpdated = .now
        }
    }
}
