import Foundation
import SwiftUI
import CoreLocation
import MapKit

// MARK: - ConditionCluster

struct ConditionCluster: Identifiable {
    var id = UUID()
    var centerCoordinate: CLLocationCoordinate2D
    var pins: [ENDOZonePin]
    var dominantCategory: SignalCategory
    var concentrationScore: Int

    var radius: Double {
        Double(50 + (concentrationScore * 15))
    }

    var dominantZone: ZoneClassification {
        let avgScore = pins.map { $0.compositeScore }.reduce(0, +) / pins.count
        return avgScore >= 66 ? .supportive :
               avgScore >= 35 ? .moderate : .hostile
    }
}

// MARK: - ConditionLayerManager

@Observable
@MainActor
final class ConditionLayerManager {

    var visibleLayers: Set<SignalCategory> = Set(SignalCategory.allCases)
    var concentrationClusters: [ConditionCluster] = []

    func toggleLayer(_ category: SignalCategory) {
        if visibleLayers.contains(category) {
            visibleLayers.remove(category)
        } else {
            visibleLayers.insert(category)
        }
    }

    func isVisible(_ category: SignalCategory) -> Bool {
        visibleLayers.contains(category)
    }

    func buildClusters(from pins: [ENDOZonePin]) {
        var clusters: [ConditionCluster] = []
        var processed = Set<UUID>()

        for pin in pins {
            guard !processed.contains(pin.id) else { continue }

            let nearby = pins.filter { other in
                other.id != pin.id &&
                !processed.contains(other.id) &&
                pin.coordinate.distance(from: other.coordinate) <= 100
            }

            if !nearby.isEmpty {
                let allInCluster = [pin] + nearby
                let cluster = ConditionCluster(
                    centerCoordinate: centroid(of: allInCluster),
                    pins: allInCluster,
                    dominantCategory: dominantCategory(of: allInCluster),
                    concentrationScore: allInCluster.count
                )
                clusters.append(cluster)
                for p in allInCluster { processed.insert(p.id) }
            } else {
                processed.insert(pin.id)
            }
        }
        concentrationClusters = clusters
    }

    private func centroid(of pins: [ENDOZonePin]) -> CLLocationCoordinate2D {
        let count = Double(pins.count)
        let avgLat = pins.map { $0.coordinate.latitude }.reduce(0, +) / count
        let avgLon = pins.map { $0.coordinate.longitude }.reduce(0, +) / count
        return CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon)
    }

    private func dominantCategory(of pins: [ENDOZonePin]) -> SignalCategory {
        let signalCounts = pins.reduce(into: [String: Int]()) {
            $0[$1.dominantSignal, default: 0] += 1
        }
        let top = signalCounts.max(by: { $0.value < $1.value })?.key ?? "Air Quality"
        return signalToCategory(top)
    }
}

// MARK: - Signal string to category mapping

func signalToCategory(_ signal: String) -> SignalCategory {
    switch signal {
    case "Heart Rate", "HRV", "SpO2", "Respiratory Rate":
        return .biometric
    case "Air Quality", "PM2.5", "Heat Index":
        return .environmental
    case "Noise Level":
        return .urbanStress
    case "Resource Density":
        return .urbanStress
    default:
        return .environmental
    }
}
