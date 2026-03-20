import SwiftUI

enum ZoneClassification: String, Codable, CaseIterable {
    case supportive = "SUPPORTIVE"
    case moderate   = "MODERATE"
    case hostile    = "HOSTILE"

    var label: String { rawValue }

    var color: Color {
        switch self {
        case .supportive: return .endoCyan
        case .moderate:   return .endoAmber
        case .hostile:    return .endoRed
        }
    }
}
