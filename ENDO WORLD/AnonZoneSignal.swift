import SwiftUI

/// Passive signal: zone ring color only.
enum AnonZoneSignal: String {
    case hostile
    case moderate
    case supportive
    case unknown

    var ringColor: Color {
        switch self {
        case .hostile:
            return Color.endoRed.opacity(0.45)
        case .moderate:
            return Color.endoAmber.opacity(0.40)
        case .supportive:
            return Color.endoGreen.opacity(0.40)
        case .unknown:
            return Color.white.opacity(0.20)
        }
    }

    static func from(
        _ zone: ZoneClassification
    ) -> AnonZoneSignal {
        switch zone {
        case .hostile: return .hostile
        case .moderate: return .moderate
        case .supportive: return .supportive
        }
    }
}
