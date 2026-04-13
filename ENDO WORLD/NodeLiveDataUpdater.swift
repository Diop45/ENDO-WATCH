import CoreLocation
import Foundation
import Observation
import SwiftUI

@Observable @MainActor
final class NodeLiveDataUpdater {

    let dataService: ENDODataService
    var isLoading: Bool = false
    var lastError: String?

    init(dataService: ENDODataService) {
        self.dataService = dataService
    }

    func updateNode(
        _ node: HealthNode
    ) async -> HealthNode {
        var updated = node
        isLoading = true
        lastError = nil

        do {
            updated = try await fetchLiveData(for: updated)
        } catch {
            lastError = error.localizedDescription
        }

        isLoading = false
        return updated
    }

    private func fetchLiveData(
        for node: HealthNode
    ) async throws -> HealthNode {
        var updated = node
        let lat = node.coordinate.latitude
        let lon = node.coordinate.longitude

        switch node.type {

        case .aqiHotspot:
            guard let obs = try await dataService.fetchAQI(
                lat: lat, lon: lon)
            else { return updated }

            let aqi = obs.aqi
            updated.envMetricValue = "\(aqi)"
            updated.envMetricColor = aqiColor(aqi)
            updated.score = max(0, 100 - aqi / 2)
            updated.envMetricLabel = "AQI"
            updated.source = "EPA AirNow"
            updated.envMetrics = [
                NodeMetric(
                    label: "AQI",
                    value: "\(aqi)",
                    color: aqiColor(aqi)),
                NodeMetric(
                    label: "PM2.5",
                    value: livePmFromAQI(aqi),
                    color: aqiColor(aqi)),
            ]

            let heatHi =
                (try? await dataService.fetchHeatIndex(
                    lat: lat, lon: lon)) ?? 75
            let bio = dataService.deriveBioContext(
                coordinate: node.coordinate,
                aqi: aqi,
                heatIndex: heatHi)
            updated.bioMetrics = liveBioMetrics(from: bio)
            updated.correlationNote =
                liveCorrelationNote(from: bio)
            updated.insightWord = liveAqiInsightWord(aqi)
            updated.interpretation = obs.category.name

        case .heatIsland:
            guard let hi = try await dataService.fetchHeatIndex(
                lat: lat, lon: lon)
            else { return updated }

            updated.envMetricValue =
                String(format: "%.0f°F", hi)
            updated.envMetricColor = liveHeatIndexColor(hi)
            updated.score = max(0, 100 - Int((hi - 70) * 2))
            updated.envMetricLabel = "Heat index"
            updated.source = "NOAA NWS"
            updated.envMetrics = [
                NodeMetric(
                    label: "Heat index",
                    value: String(format: "%.0f°F", hi),
                    color: liveHeatIndexColor(hi)),
                NodeMetric(
                    label: "vs avg",
                    value: liveHeatDelta(hi),
                    color: liveHeatIndexColor(hi)),
            ]

            let bio = dataService.deriveBioContext(
                coordinate: node.coordinate,
                aqi: 50,
                heatIndex: hi)
            updated.bioMetrics = [
                NodeMetric(
                    label: "HR impact",
                    value: bio.heatHRDelta > 0
                        ? "+\(bio.heatHRDelta) bpm"
                        : "None",
                    color: bio.heatHRDelta > 10
                        ? Color.endoRed : Color.endoAmber),
                NodeMetric(
                    label: "Risk",
                    value: liveHeatRiskLabel(hi),
                    color: liveHeatIndexColor(hi)),
            ]
            updated.insightWord = liveHeatInsightWord(hi)

        case .envEvent:
            let alerts = try await dataService.fetchWeatherAlerts(
                lat: lat, lon: lon)
            updated.source = "NOAA NWS Alerts"
            if let first = alerts.first {
                let props = first.properties
                updated.envMetricValue = props.severity
                updated.title = props.event
                updated.interpretation =
                    props.headline ?? props.event
                updated.insightWord = "\(props.severity)."
            }

        case .diabetesCluster:
            guard let record = try await dataService.fetchCDCPlaces(
                lat: lat,
                lon: lon,
                measure: "DIABETES")
            else { return updated }

            if let val = record.dataValueDouble {
                updated.envMetricValue =
                    String(format: "%.1f%%", val)
                updated.score = max(0, 100 - Int(val * 5))
                updated.source = "CDC PLACES"
                updated.envMetrics = [
                    NodeMetric(
                        label: "Prevalence",
                        value: String(format: "%.1f%%", val),
                        color: liveDiabetesColor(val)),
                    NodeMetric(
                        label: "vs city avg",
                        value: liveRatioLabel(val, 5.9),
                        color: liveDiabetesColor(val)),
                ]
                updated.bioMetrics = [
                    NodeMetric(
                        label: "Metabolic risk",
                        value: liveMetabolicRisk(val),
                        color: liveDiabetesColor(val)),
                    NodeMetric(
                        label: "Delay risk",
                        value: "2.8x",
                        color: Color.endoAmber),
                ]
            }

        case .hypertensionZone:
            guard let record = try await dataService.fetchCDCPlaces(
                lat: lat,
                lon: lon,
                measure: "BPHIGH")
            else { return updated }

            if let val = record.dataValueDouble {
                updated.envMetricValue =
                    String(format: "%.1f%%", val)
                updated.source = "CDC PLACES"
                updated.envMetrics = [
                    NodeMetric(
                        label: "Hypertension",
                        value: String(format: "%.1f%%", val),
                        color: Color.endoRed),
                    NodeMetric(
                        label: "vs city avg",
                        value: liveRatioLabel(val, 32.0),
                        color: Color.endoAmber),
                ]
            }

        case .asthmaRisk:
            var hadAqi = false
            var hadCdc = false

            if let obs = try await dataService.fetchAQI(
                lat: lat, lon: lon)
            {
                hadAqi = true
                let aqi = obs.aqi
                updated.envMetricValue = "\(aqi)"
                updated.envMetricColor = aqiColor(aqi)
                updated.score = max(0, 100 - aqi / 2)
                updated.envMetricLabel = "AQI"
                updated.envMetrics = [
                    NodeMetric(
                        label: "AQI",
                        value: "\(aqi)",
                        color: aqiColor(aqi)),
                    NodeMetric(
                        label: "PM2.5",
                        value: livePmFromAQI(aqi),
                        color: aqiColor(aqi)),
                ]
                let heatHi =
                    (try? await dataService.fetchHeatIndex(
                        lat: lat, lon: lon)) ?? 75
                let bio = dataService.deriveBioContext(
                    coordinate: node.coordinate,
                    aqi: aqi,
                    heatIndex: heatHi)
                updated.bioMetrics = liveBioMetrics(from: bio)
                updated.correlationNote =
                    liveCorrelationNote(from: bio)
                updated.insightWord = liveAqiInsightWord(aqi)
                updated.interpretation = obs.category.name
            }

            if let record = try await dataService.fetchCDCPlaces(
                lat: lat,
                lon: lon,
                measure: "CASTHMA"),
               let val = record.dataValueDouble
            {
                hadCdc = true
                let tag =
                    "Asthma prevalence "
                    + String(format: "%.1f%%", val)
                if !updated.relatedFactors.contains(tag) {
                    updated.relatedFactors.append(tag)
                }
            }

            if hadAqi, hadCdc {
                updated.source = "EPA AirNow + CDC PLACES"
            } else if hadAqi {
                updated.source = "EPA AirNow"
            } else if hadCdc {
                updated.source = "CDC PLACES"
            }

        case .noiseExposure:
            if let obs = try await dataService.fetchAQI(
                lat: lat, lon: lon)
            {
                let aqi = obs.aqi
                let bio = dataService.deriveBioContext(
                    coordinate: node.coordinate,
                    aqi: aqi,
                    heatIndex: 78,
                    noiseDB: 82)
                updated.bioMetrics = liveBioMetrics(from: bio)
                updated.correlationNote =
                    liveCorrelationNote(from: bio)
                updated.source = "EPA AirNow (air) · modeled noise"
            }

        case .hospital, .clinic, .pharmacy,
             .careDesert, .foodDesert,
             .foodAccess, .socialVulnerability,
             .greenSpace, .walkabilityZone,
             .communityChallenge, .zoneCondition:
            break
        }

        return updated
    }
}

private func liveBioMetrics(
    from bio: DerivedBioContext
) -> [NodeMetric] {
    [
        NodeMetric(
            label: "Expected HR",
            value: bio.expectedHRDisplay,
            color: liveHrColorFromExpected(bio.expectedHR)),
        NodeMetric(
            label: "HRV impact",
            value: bio.hrvSuppressionDisplay,
            color: bio.expectedHRVSuppression > 10
                ? Color.endoRed : Color.endoAmber),
    ]
}

private func liveCorrelationNote(
    from bio: DerivedBioContext
) -> String {
    if bio.hrDeltaDisplay.contains("+") {
        return
            "People in this zone show "
            + bio.hrDeltaDisplay
            + " and "
            + bio.hrvSuppressionDisplay
            + " HRV. Sustained exposure "
            + "increases cardiovascular load."
    }
    return
        "Air quality within normal range. "
        + "No significant biometric impact expected."
}

private func liveAqiInsightWord(_ aqi: Int) -> String {
    switch aqi {
    case ..<51: return "Clean."
    case ..<101: return "Moderate."
    case ..<151: return "Unhealthy."
    case ..<201: return "Very unhealthy."
    default: return "Hazardous."
    }
}

private func liveHeatIndexColor(
    _ hi: Double
) -> Color {
    switch hi {
    case ..<80: return Color.endoGreen
    case ..<90: return Color(hex: "#FFD700")
    case ..<103: return Color.endoAmber
    case ..<124: return Color.endoRed
    default: return Color(hex: "#7E0023")
    }
}

private func liveHeatInsightWord(_ hi: Double) -> String {
    switch hi {
    case ..<80: return "Comfortable."
    case ..<90: return "Warm."
    case ..<103: return "Hot."
    case ..<124: return "Dangerous."
    default: return "Emergency."
    }
}

private func liveHeatRiskLabel(_ hi: Double) -> String {
    switch hi {
    case ..<80: return "Low"
    case ..<90: return "Moderate"
    case ..<103: return "High"
    default: return "Critical"
    }
}

private func liveHeatDelta(_ hi: Double) -> String {
    let avg = 82.0
    let delta = hi - avg
    if delta > 0 {
        return String(format: "+%.0f°F avg", delta)
    }
    return String(format: "%.0f°F avg", delta)
}

private func livePmFromAQI(_ aqi: Int) -> String {
    let pm = Double(aqi) * 0.35
    return String(format: "%.1f µg/m³", pm)
}

private func liveHrColorFromExpected(_ hr: Int) -> Color {
    switch hr {
    case ..<75: return Color.endoGreen
    case ..<85: return Color.endoAmber
    default: return Color.endoRed
    }
}

private func liveDiabetesColor(
    _ prevalence: Double
) -> Color {
    switch prevalence {
    case ..<8: return Color.endoAmber
    case ..<14: return Color.endoRed
    default: return Color(hex: "#7E0023")
    }
}

private func liveMetabolicRisk(
    _ prevalence: Double
) -> String {
    switch prevalence {
    case ..<8: return "Elevated"
    case ..<14: return "High"
    default: return "Critical"
    }
}

private func liveRatioLabel(
    _ value: Double,
    _ cityAvg: Double
) -> String {
    let ratio = value / cityAvg
    return String(format: "%.1fx avg", ratio)
}
