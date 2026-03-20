import Foundation
import CoreLocation
import WatchConnectivity

// MARK: - Constants

private let appGroupID    = "group.com.endoworld.endo"
private let scanResultKey = "endo.lastScanResult"

// MARK: - ScanService
// Orchestrates a single on-demand scan:
//   1. One-shot GPS fix via CLLocationManager
//   2. Three concurrent requests: EPA AirNow · CDC PLACES · CommunityFeedRegistry
//   3. Packages a ScanResult
//   4. Persists to shared App Group UserDefaults
//   5. Fires WCSession.transferUserInfo to the paired iPhone

@Observable
@MainActor
final class ScanService: NSObject {

    private let liveData        = LiveDataService()
    private let locationManager = CLLocationManager()

    // Continuation for the one-shot location request. Nilled after use.
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    // MARK: - Init

    override init() {
        super.init()
        locationManager.delegate        = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - Perform scan

    func performScan() async throws -> ScanResult {
        let location = try await fetchLocation()
        let coord    = location.coordinate

        // Three concurrent network requests as specified.
        async let aqiTask       = liveData.fetchAQI(coordinate: coord)
        async let cdcTask       = fetchCDCData(location: location)          // side-effect: loads liveData.cdcRecords
        async let communityTask = fetchCommunityScores(coordinate: coord)

        let (aqiData, _, communityScores) = await (aqiTask, cdcTask, communityTask)

        let result = ScanResult(
            airQualityIndex:       aqiData.aqi,
            communityHealthScores: communityScores,
            timestamp:             .now,
            coordinate:            coord
        )

        persistResult(result)
        transferToPhone(result)
        return result
    }

    // MARK: - CommunityFeedRegistry
    // Fetches nearby anonymous zone pins and returns their composite scores (0–100).

    private func fetchCommunityScores(coordinate: CLLocationCoordinate2D) async -> [Double] {
        var components = URLComponents(string: Config.backendBaseURL + "/pins/neighborhood")
        components?.queryItems = [
            URLQueryItem(name: "lat",    value: String(coordinate.latitude)),
            URLQueryItem(name: "lon",    value: String(coordinate.longitude)),
            URLQueryItem(name: "radius", value: "2.0"),
        ]
        guard let url = components?.url else { return [] }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let pins = try JSONDecoder().decode([ENDOZonePin].self, from: data)
            return pins.map { Double($0.compositeScore) }
        } catch {
            return []
        }
    }

    // MARK: - CDC PLACES
    // Reverse-geocodes the location to a city name then delegates to LiveDataService.

    private func fetchCDCData(location: CLLocation) async {
        let city = await resolvedCity(from: location)
        await liveData.fetchCDCPlaces(city: city)
    }

    private func resolvedCity(from location: CLLocation) async -> String {
        await withCheckedContinuation { continuation in
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
                continuation.resume(returning: placemarks?.first?.locality ?? "Detroit")
            }
        }
    }

    // MARK: - Persist

    private func persistResult(_ result: ScanResult) {
        let defaults = UserDefaults(suiteName: appGroupID) ?? .standard
        guard let encoded = try? JSONEncoder().encode(result) else { return }
        defaults.set(encoded, forKey: scanResultKey)
    }

    // MARK: - WCSession transfer

    private func transferToPhone(_ result: ScanResult) {
        guard WCSession.isSupported(),
              WCSession.default.activationState == .activated else { return }
        WCSession.default.transferUserInfo([
            "aqi":       result.airQualityIndex,
            "zone":      result.zoneLabel.rawValue,
            "timestamp": result.timestamp.timeIntervalSince1970,
            "lat":       result.latitude,
            "lon":       result.longitude,
        ])
    }

    // MARK: - One-shot location

    private func fetchLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension ScanService: CLLocationManagerDelegate {

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            locationContinuation?.resume(returning: location)
            locationContinuation = nil
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        Task { @MainActor in
            locationContinuation?.resume(throwing: error)
            locationContinuation = nil
        }
    }
}

// MARK: - WCSessionDelegate

extension ScanService: WCSessionDelegate {

    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        // Activation complete — transferUserInfo is now available.
    }
}
