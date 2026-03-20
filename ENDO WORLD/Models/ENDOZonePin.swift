import Foundation
import CoreLocation

struct ENDOZonePin: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var coordinate: CLLocationCoordinate2D
    var zone: ZoneClassification
    var compositeScore: Int
    var dominantSignal: String
    var timestamp: Date
    var isAnonymous: Bool
    var tractID: String
    var contributorHash: String

    enum CodingKeys: String, CodingKey {
        case id, zone, compositeScore, dominantSignal, timestamp
        case isAnonymous, tractID, contributorHash
        case latitude, longitude
    }

    init(
        id: UUID = UUID(),
        coordinate: CLLocationCoordinate2D,
        zone: ZoneClassification,
        compositeScore: Int,
        dominantSignal: String,
        timestamp: Date = .now,
        isAnonymous: Bool = false,
        tractID: String = "",
        contributorHash: String = ""
    ) {
        self.id = id
        self.coordinate = coordinate
        self.zone = zone
        self.compositeScore = compositeScore
        self.dominantSignal = dominantSignal
        self.timestamp = timestamp
        self.isAnonymous = isAnonymous
        self.tractID = tractID
        self.contributorHash = contributorHash
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        zone = try c.decode(ZoneClassification.self, forKey: .zone)
        compositeScore = try c.decode(Int.self, forKey: .compositeScore)
        dominantSignal = try c.decode(String.self, forKey: .dominantSignal)
        timestamp = try c.decode(Date.self, forKey: .timestamp)
        isAnonymous = try c.decode(Bool.self, forKey: .isAnonymous)
        tractID = try c.decode(String.self, forKey: .tractID)
        contributorHash = try c.decode(String.self, forKey: .contributorHash)
        let lat = try c.decode(Double.self, forKey: .latitude)
        let lon = try c.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(zone, forKey: .zone)
        try c.encode(compositeScore, forKey: .compositeScore)
        try c.encode(dominantSignal, forKey: .dominantSignal)
        try c.encode(timestamp, forKey: .timestamp)
        try c.encode(isAnonymous, forKey: .isAnonymous)
        try c.encode(tractID, forKey: .tractID)
        try c.encode(contributorHash, forKey: .contributorHash)
        try c.encode(coordinate.latitude, forKey: .latitude)
        try c.encode(coordinate.longitude, forKey: .longitude)
    }

    static func == (lhs: ENDOZonePin, rhs: ENDOZonePin) -> Bool {
        lhs.id == rhs.id
    }
}
