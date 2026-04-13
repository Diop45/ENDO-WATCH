import CoreLocation
import Foundation
import SwiftUI

enum NodeLens: String, CaseIterable, Hashable {
    case all = "All"
    case behavior = "Behavior"
    case care = "Care"
    case outcome = "Outcome"

    var color: Color {
        switch self {
        case .all: .endoCyan
        case .behavior: Color(hex: "#378ADD")
        case .care: .endoGreen
        case .outcome: .endoPurple
        }
    }
}

enum NodeType: String, CaseIterable {
    // Outcome lens — hostile/warning
    case aqiHotspot
    case heatIsland
    case noiseExposure
    case diabetesCluster
    case asthmaRisk
    case hypertensionZone
    case socialVulnerability
    case envEvent

    // Care lens — resource/positive
    case hospital
    case clinic
    case pharmacy
    case careDesert
    case foodAccess
    case foodDesert

    // Behavior lens — opportunity/positive
    case greenSpace
    case walkabilityZone
    case communityChallenge
    case zoneCondition

    var icon: String {
        switch self {
        case .aqiHotspot,
             .zoneCondition:
            "wind"
        case .heatIsland:
            "thermometer.sun.fill"
        case .noiseExposure:
            "speaker.wave.3.fill"
        case .diabetesCluster:
            "drop.fill"
        case .asthmaRisk:
            "lungs.fill"
        case .hypertensionZone:
            "heart.fill"
        case .socialVulnerability:
            "person.3.fill"
        case .envEvent:
            "exclamationmark.triangle.fill"
        case .hospital:
            "cross.circle.fill"
        case .clinic:
            "stethoscope"
        case .pharmacy:
            "pills.fill"
        case .careDesert:
            "exclamationmark.triangle.fill"
        case .foodAccess:
            "cart.fill"
        case .foodDesert:
            "cart.badge.minus"
        case .greenSpace:
            "leaf.fill"
        case .walkabilityZone:
            "figure.walk"
        case .communityChallenge:
            "flag.fill"
        }
    }

    var defaultLens: NodeLens {
        switch self {
        case .aqiHotspot,
             .heatIsland,
             .noiseExposure,
             .diabetesCluster,
             .asthmaRisk,
             .hypertensionZone,
             .socialVulnerability,
             .envEvent:
            .outcome
        case .hospital,
             .clinic,
             .pharmacy,
             .careDesert,
             .foodAccess,
             .foodDesert:
            .care
        case .greenSpace,
             .walkabilityZone,
             .communityChallenge,
             .zoneCondition:
            .behavior
        }
    }

    /// Cadence for data refresh
    var cadence: NodeCadence {
        switch self {
        case .aqiHotspot,
             .heatIsland,
             .noiseExposure,
             .asthmaRisk:
            .live
        case .envEvent:
            .ephemeral
        case .diabetesCluster,
             .hypertensionZone,
             .socialVulnerability,
             .hospital,
             .clinic,
             .pharmacy,
             .careDesert,
             .foodAccess,
             .foodDesert,
             .greenSpace,
             .walkabilityZone,
             .communityChallenge,
             .zoneCondition:
            .permanent
        }
    }

    /// Whether node is a warning or a resource
    var isPositive: Bool {
        switch self {
        case .hospital, .clinic,
             .pharmacy, .foodAccess,
             .greenSpace, .walkabilityZone,
             .communityChallenge,
             .zoneCondition:
            return true
        default:
            return false
        }
    }
}

enum NodeCadence {
    case live  // hourly API
    case ephemeral  // event-driven
    case permanent  // quarterly/annual
}

enum NodeProximityState {
    case idle
    case nearby
    case autoReveal
    case selected
    case visited
}

struct NodeMetric: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let color: Color
}

struct NodeAction: Identifiable {
    let id: String
    let label: String
    let isPrimary: Bool
}

struct HealthNode: Identifiable, Equatable {
    let id: String
    var coordinate: CLLocationCoordinate2D
    var type: NodeType
    var lenses: [NodeLens]
    var title: String
    var subtitle: String
    var score: Int?
    var envMetricLabel: String
    var envMetricValue: String
    var envMetricColor: Color
    var insightWord: String
    var interpretation: String
    var whyItMatters: String
    var correlationNote: String
    var actions: [NodeAction]
    var relatedFactors: [String]
    var envMetrics: [NodeMetric]
    var bioMetrics: [NodeMetric]
    var trendHistory: [Double]
    var historyLabel: String
    var source: String
    var proximityState: NodeProximityState
    var isLoadingLiveData: Bool = false
    var lastRefreshedAt: Date? = nil

    var primaryLens: NodeLens {
        lenses.first ?? .outcome
    }

    static func == (
        lhs: HealthNode,
        rhs: HealthNode
    ) -> Bool { lhs.id == rhs.id }
}

/// Compound node — multiple types
/// in the same H3 cell
struct CompoundNode: Identifiable {
    let id: String
    var coordinate: CLLocationCoordinate2D
    var constituents: [HealthNode]
    var proximityState: NodeProximityState

    /// Worst-case color wins
    var dominantColor: Color {
        let hostile = constituents.filter {
            !$0.type.isPositive
        }
        if let first = hostile.first {
            return first.primaryLens.color
        }
        return constituents.first?.primaryLens.color ?? .endoCyan
    }

    /// Highest severity constituent leads
    var leadNode: HealthNode {
        let sorted = constituents.sorted { lhs, rhs in
            if lhs.type.isPositive != rhs.type.isPositive {
                return !lhs.type.isPositive && rhs.type.isPositive
            }
            return lhs.id < rhs.id
        }
        return sorted.first ?? constituents[0]
    }

    var title: String {
        "\(constituents.count) conditions"
    }

    var subtitle: String {
        constituents.prefix(3)
            .map(\.type.rawValue)
            .joined(separator: " · ")
    }
}
