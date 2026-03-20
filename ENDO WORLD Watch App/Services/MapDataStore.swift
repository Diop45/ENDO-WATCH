import Foundation
import CoreLocation

private let scoreHistoryMaxCount = 5

// MARK: - ENDOZonePin

struct ENDOZonePin: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var coordinate: CLLocationCoordinate2D
    var zone: ZoneClassification
    var compositeScore: Int
    var dominantSignal: String
    var timestamp: Date
    var isAnonymous: Bool
    var tractID: String         // Census GEOID
    var contributorHash: String // SHA256 of device ID — not reversible

    // MARK: - Codable (CLLocationCoordinate2D is not Codable natively)

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
        self.id              = id
        self.coordinate      = coordinate
        self.zone            = zone
        self.compositeScore  = compositeScore
        self.dominantSignal  = dominantSignal
        self.timestamp       = timestamp
        self.isAnonymous     = isAnonymous
        self.tractID         = tractID
        self.contributorHash = contributorHash
    }

    init(from decoder: Decoder) throws {
        let c           = try decoder.container(keyedBy: CodingKeys.self)
        id              = try c.decode(UUID.self,               forKey: .id)
        zone            = try c.decode(ZoneClassification.self, forKey: .zone)
        compositeScore  = try c.decode(Int.self,                forKey: .compositeScore)
        dominantSignal  = try c.decode(String.self,             forKey: .dominantSignal)
        timestamp       = try c.decode(Date.self,               forKey: .timestamp)
        isAnonymous     = try c.decode(Bool.self,               forKey: .isAnonymous)
        tractID         = try c.decode(String.self,             forKey: .tractID)
        contributorHash = try c.decode(String.self,             forKey: .contributorHash)
        let lat         = try c.decode(Double.self,             forKey: .latitude)
        let lon         = try c.decode(Double.self,             forKey: .longitude)
        coordinate      = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,              forKey: .id)
        try c.encode(zone,            forKey: .zone)
        try c.encode(compositeScore,  forKey: .compositeScore)
        try c.encode(dominantSignal,  forKey: .dominantSignal)
        try c.encode(timestamp,       forKey: .timestamp)
        try c.encode(isAnonymous,     forKey: .isAnonymous)
        try c.encode(tractID,         forKey: .tractID)
        try c.encode(contributorHash, forKey: .contributorHash)
        try c.encode(coordinate.latitude,  forKey: .latitude)
        try c.encode(coordinate.longitude, forKey: .longitude)
    }

    static func == (lhs: ENDOZonePin, rhs: ENDOZonePin) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - MapDataStore

@Observable
@MainActor
class MapDataStore {

    var personalPin: ENDOZonePin?
    var neighborhoodPins: [ENDOZonePin] = []
    private(set) var scoreHistory: [Int] = []

    private var neighborhoodRefreshTask: Task<Void, Never>?

    // MARK: - Personal pin

    func updatePersonalPin(
        fusionOutput: FusionOutput,
        coordinate: CLLocationCoordinate2D,
        tractID: String
    ) {
        personalPin = ENDOZonePin(
            coordinate: coordinate,
            zone: fusionOutput.zone,
            compositeScore: fusionOutput.compositeScore,
            dominantSignal: fusionOutput.dominantSignal,
            tractID: tractID
        )
        var next = scoreHistory + [fusionOutput.compositeScore]
        if next.count > scoreHistoryMaxCount { next.removeFirst() }
        scoreHistory = next
    }

    // MARK: - Anonymous submission

    func submitAnonymousPin(_ pin: ENDOZonePin) async {
        var sanitized = pin
        // Privacy rule 1: round coordinates to 3 decimal places (~110 m precision)
        sanitized.coordinate = roundedCoordinate(pin.coordinate)
        // Privacy rule 2: truncate timestamp to hour only
        sanitized.timestamp  = truncateToHour(pin.timestamp)
        sanitized.isAnonymous = true
        // Strip tract only — keep contributorHash (one-way hash, safe to transmit)

        guard let url = URL(string: Config.backendBaseURL + "/pins") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(sanitized)
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) {
                neighborhoodPins.append(sanitized)
            }
        } catch {
            // Network failure — submission silently dropped
        }
    }

    // MARK: - Neighborhood fetch

    func fetchNeighborhoodPins(coordinate: CLLocationCoordinate2D, radiusMiles: Double) async {
        var components = URLComponents(string: Config.backendBaseURL + "/pins/neighborhood")
        components?.queryItems = [
            .init(name: "lat",    value: String(coordinate.latitude)),
            .init(name: "lon",    value: String(coordinate.longitude)),
            .init(name: "radius", value: String(radiusMiles))
        ]
        guard let url = components?.url else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let pins = try JSONDecoder().decode([ENDOZonePin].self, from: data)
            neighborhoodPins = pins
        } catch {
            // Retain last known neighborhood pins on failure
        }
    }

    // MARK: - Repeating refresh

    func startNeighborhoodRefresh(coordinate: CLLocationCoordinate2D, radiusMiles: Double = 2.0) {
        neighborhoodRefreshTask?.cancel()
        neighborhoodRefreshTask = Task {
            while !Task.isCancelled {
                await fetchNeighborhoodPins(coordinate: coordinate, radiusMiles: radiusMiles)
                try? await Task.sleep(for: .seconds(300)) // 5 minutes
            }
        }
    }

    func stopNeighborhoodRefresh() {
        neighborhoodRefreshTask?.cancel()
        neighborhoodRefreshTask = nil
    }

    // MARK: - Privacy helpers

    private func roundedCoordinate(_ coord: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let lat = (coord.latitude  * 1000).rounded() / 1000
        let lon = (coord.longitude * 1000).rounded() / 1000
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    private func truncateToHour(_ date: Date) -> Date {
        let cal = Calendar.current
        return cal.date(
            from: cal.dateComponents([.year, .month, .day, .hour], from: date)
        ) ?? date
    }
}
