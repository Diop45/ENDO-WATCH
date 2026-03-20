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

    /// Pulse duration for breathing zone pins (seconds)
    var pulseDuration: Double {
        switch self {
        case .hostile:    return 1.2
        case .moderate:   return 1.8
        case .supportive: return 2.4
        }
    }

    /// Condition field radius in meters
    var conditionRadius: Double {
        switch self {
        case .hostile:    return 90
        case .moderate:   return 60
        case .supportive: return 70
        }
    }
}
