import SwiftUI

enum ZoneClassification: String, Codable, CaseIterable {
    case hostile
    case moderate
    case supportive

    var label: String {
        rawValue.uppercased()
    }

    var color: Color {
        switch self {
        case .hostile:    return .endoHostile
        case .moderate:   return .endoModerate
        case .supportive: return .endoCyan
        }
    }
}
