import Foundation
import CoreLocation

struct EnvironmentalReading: Codable {
    var aqi: Int                // EPA Air Quality Index
    var pm25: Double            // Particulate matter µg/m³
    var noiseLevel: Double      // dB
    var heatIndex: Double       // °F
    var coordinate: CLLocationCoordinate2D
    var timestamp: Date
    var dataSource: String      // "EPA", "CDC", etc.

    // MARK: - Init

    init(
        aqi: Int,
        pm25: Double,
        noiseLevel: Double,
        heatIndex: Double,
        coordinate: CLLocationCoordinate2D,
        timestamp: Date,
        dataSource: String
    ) {
        self.aqi = aqi
        self.pm25 = pm25
        self.noiseLevel = noiseLevel
        self.heatIndex = heatIndex
        self.coordinate = coordinate
        self.timestamp = timestamp
        self.dataSource = dataSource
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case aqi, pm25, noiseLevel, heatIndex, timestamp, dataSource
        case latitude, longitude
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        aqi        = try c.decode(Int.self,    forKey: .aqi)
        pm25       = try c.decode(Double.self, forKey: .pm25)
        noiseLevel = try c.decode(Double.self, forKey: .noiseLevel)
        heatIndex  = try c.decode(Double.self, forKey: .heatIndex)
        timestamp  = try c.decode(Date.self,   forKey: .timestamp)
        dataSource = try c.decode(String.self, forKey: .dataSource)
        let lat    = try c.decode(Double.self, forKey: .latitude)
        let lon    = try c.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(aqi,                    forKey: .aqi)
        try c.encode(pm25,                   forKey: .pm25)
        try c.encode(noiseLevel,             forKey: .noiseLevel)
        try c.encode(heatIndex,              forKey: .heatIndex)
        try c.encode(timestamp,              forKey: .timestamp)
        try c.encode(dataSource,             forKey: .dataSource)
        try c.encode(coordinate.latitude,    forKey: .latitude)
        try c.encode(coordinate.longitude,   forKey: .longitude)
    }

    // Detroit default mock
    static let mock = EnvironmentalReading(
        aqi: 52,
        pm25: 12.4,
        noiseLevel: 68,
        heatIndex: 74,
        coordinate: CLLocationCoordinate2D(latitude: 42.3314, longitude: -83.0458),
        timestamp: .now,
        dataSource: "EPA"
    )
}
