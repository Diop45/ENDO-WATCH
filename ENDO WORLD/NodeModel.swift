import CoreLocation
import Foundation
import SwiftUI

enum NodeLens: String, CaseIterable {
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
    case aqiHotspot
    case zoneCondition
    case hospital
    case clinic
    case pharmacy
    case careDesert
    case diabetesCluster
    case asthmaRisk
    case hypertensionZone
    case communityChallenge
    case healthFair

    var icon: String {
        switch self {
        case .aqiHotspot, .zoneCondition: "wind"
        case .hospital: "cross.circle.fill"
        case .clinic: "stethoscope"
        case .pharmacy: "pills.fill"
        case .careDesert: "exclamationmark.triangle.fill"
        case .diabetesCluster: "drop.fill"
        case .asthmaRisk: "lungs.fill"
        case .hypertensionZone: "heart.fill"
        case .communityChallenge, .healthFair: "flag.fill"
        }
    }

    var defaultLens: NodeLens {
        switch self {
        case .aqiHotspot, .zoneCondition, .diabetesCluster, .asthmaRisk, .hypertensionZone: .outcome
        case .hospital, .clinic, .pharmacy, .careDesert: .care
        case .communityChallenge, .healthFair: .behavior
        }
    }
}

enum NodeState {
    case idle, nearby, selected, visited, active
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

    var source: String
    var state: NodeState

    var primaryLens: NodeLens {
        lenses.first ?? .outcome
    }

    static func == (lhs: HealthNode, rhs: HealthNode) -> Bool {
        lhs.id == rhs.id
    }
}
