import SwiftUI

enum ZoneClassification: String, Codable {
    case supportive = "Supportive"
    case moderate = "Moderate"
    case hostile = "Hostile"

    var color: Color {
        switch self {
        case .supportive: .endoGreen
        case .moderate: .endoAmber
        case .hostile: .endoRed
        }
    }

    var bgTint: Color { color.opacity(0.08) }
    var borderTint: Color { color.opacity(0.22) }

    static func from(_ score: Int)
        -> ZoneClassification
    {
        score >= 66 ? .supportive
            : score >= 35 ? .moderate
            : .hostile
    }
}
