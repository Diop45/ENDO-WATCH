import SwiftUI
import CoreLocation

// MARK: - ScanZoneLabel
// Derived from the average of communityHealthScores (0–100, higher = more supportive).
// Uses the same thresholds as ZoneFusionEngine but maps to the watch-face vocabulary.

enum ScanZoneLabel: String, Codable, CaseIterable {
    case clear    = "CLEAR"
    case moderate = "MODERATE"
    case hostile  = "HOSTILE"

    var color: Color {
        switch self {
        case .clear:    return Color(hex: "#34C759")
        case .moderate: return Color(hex: "#FFD60A")
        case .hostile:  return Color(hex: "#FF453A")
        }
    }
}

// MARK: - ScanResult
// Produced by ScanService on each on-demand scan.
// Persisted to the shared App Group and transferred to the paired iPhone.

struct ScanResult: Codable {
    var id: UUID
    var airQualityIndex: Int
    var communityHealthScores: [Double]   // composite scores (0–100) from nearby pins
    var timestamp: Date

    // CLLocationCoordinate2D is not natively Codable; store as primitives.
    var latitude: Double
    var longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // MARK: - Zone derivation

    var zoneLabel: ScanZoneLabel {
        guard !communityHealthScores.isEmpty else { return .moderate }
        let avg = communityHealthScores.reduce(0, +) / Double(communityHealthScores.count)
        switch avg {
        case 66...100: return .clear
        case 35...65:  return .moderate
        default:       return .hostile
        }
    }

    // MARK: - Init

    init(
        id: UUID = UUID(),
        airQualityIndex: Int,
        communityHealthScores: [Double],
        timestamp: Date = .now,
        coordinate: CLLocationCoordinate2D
    ) {
        self.id                    = id
        self.airQualityIndex       = airQualityIndex
        self.communityHealthScores = communityHealthScores
        self.timestamp             = timestamp
        self.latitude              = coordinate.latitude
        self.longitude             = coordinate.longitude
    }
}
