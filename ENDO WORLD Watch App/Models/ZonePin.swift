import Foundation
import CoreLocation

struct ZonePin: Identifiable, Codable {
    var id: UUID
    var coordinate: CLLocationCoordinate2D
    var classification: ZoneClassification
    var timestamp: Date
    var environmentalScore: Double
    var biometricScore: Double

    // MARK: - Init

    init(
        id: UUID = UUID(),
        coordinate: CLLocationCoordinate2D,
        classification: ZoneClassification,
        timestamp: Date = .now,
        environmentalScore: Double,
        biometricScore: Double
    ) {
        self.id = id
        self.coordinate = coordinate
        self.classification = classification
        self.timestamp = timestamp
        self.environmentalScore = environmentalScore
        self.biometricScore = biometricScore
    }

    // MARK: - Codable (CLLocationCoordinate2D is not Codable by default)

    enum CodingKeys: String, CodingKey {
        case id, classification, timestamp, environmentalScore, biometricScore
        case latitude, longitude
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id                 = try c.decode(UUID.self,               forKey: .id)
        classification     = try c.decode(ZoneClassification.self, forKey: .classification)
        timestamp          = try c.decode(Date.self,               forKey: .timestamp)
        environmentalScore = try c.decode(Double.self,             forKey: .environmentalScore)
        biometricScore     = try c.decode(Double.self,             forKey: .biometricScore)
        let lat            = try c.decode(Double.self,             forKey: .latitude)
        let lon            = try c.decode(Double.self,             forKey: .longitude)
        coordinate         = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,                 forKey: .id)
        try c.encode(classification,     forKey: .classification)
        try c.encode(timestamp,          forKey: .timestamp)
        try c.encode(environmentalScore, forKey: .environmentalScore)
        try c.encode(biometricScore,     forKey: .biometricScore)
        try c.encode(coordinate.latitude,  forKey: .latitude)
        try c.encode(coordinate.longitude, forKey: .longitude)
    }
}
