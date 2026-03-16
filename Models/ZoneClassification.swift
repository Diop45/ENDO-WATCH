import SwiftUI

enum ZoneClassification: String, Codable, CaseIterable {
    case supportive = "SUPPORTIVE"
    case moderate   = "MODERATE"
    case hostile    = "HOSTILE"

    var label: String { rawValue }

    var color: Color {
        switch self {
        case .supportive: return Color(hex: "#34C759")
        case .moderate:   return Color(hex: "#FF9F0A")
        case .hostile:    return Color(hex: "#FF3B3B")
        }
    }
}
