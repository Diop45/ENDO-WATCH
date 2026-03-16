import Foundation
import CoreLocation

// MARK: - LocationService
// Orchestrates the full pipeline: location → env data → fusion → pin update → share prompt.
// Inherits NSObject to satisfy CLLocationManagerDelegate's NSObjectProtocol requirement.

@Observable
@MainActor
final class LocationService: NSObject {

    var currentCoordinate: CLLocationCoordinate2D?
    var currentTractID: String = ""

    // Injected dependencies
    private let liveDataService: LiveDataService
    private let fusionEngine: ZoneFusionEngine
    private let dataStore: MapDataStore
    private let shareService: AnonymousShareService

    // Set after init to avoid circular dependency
    weak var streamService: BiometricStreamService?

    private let manager = CLLocationManager()
    private var lastPipelineRunTime: Date = .distantPast
    private let minimumUpdateInterval: TimeInterval = 30

    // MARK: - Init

    init(
        liveDataService: LiveDataService,
        fusionEngine: ZoneFusionEngine,
        dataStore: MapDataStore,
        shareService: AnonymousShareService
    ) {
        self.liveDataService = liveDataService
        self.fusionEngine    = fusionEngine
        self.dataStore       = dataStore
        self.shareService    = shareService
        super.init()
        manager.delegate          = self
        manager.desiredAccuracy   = kCLLocationAccuracyNearestTenMeters
        manager.distanceFilter    = 50  // trigger on ~50 m change
        manager.pausesLocationUpdatesAutomatically = false
    }

    // MARK: - Tracking

    func startTracking() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.startMonitoringSignificantLocationChanges()
    }

    func stopTracking() {
        manager.stopUpdatingLocation()
        manager.stopMonitoringSignificantLocationChanges()
    }

    // MARK: - Pipeline

    func runPipeline(coordinate: CLLocationCoordinate2D) async {
        let snapshot = await liveDataService.fetchAll(coordinate: coordinate)
        currentTractID = snapshot.tractID

        let input = FusionInput(
            heartRate:       streamService?.heartRate       ?? 0,
            hrv:             streamService?.hrv             ?? 0,
            spo2:            streamService?.spo2            ?? 0,
            noiseLevel:      streamService?.noiseLevel      ?? 0,
            respiratoryRate: streamService?.respiratoryRate ?? 0,
            aqi:             snapshot.aqi,
            pm25:            snapshot.pm25,
            heatIndex:       snapshot.heatIndex,
            resourceDensity: snapshot.resourceDensity
        )

        let output = fusionEngine.fuse(input)
        dataStore.updatePersonalPin(fusionOutput: output, coordinate: coordinate, tractID: snapshot.tractID)
        shareService.promptIfNeeded(after: dataStore)
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }
        let coordinate = location.coordinate
        let now = Date()

        Task { @MainActor [weak self] in
            guard let self else { return }
            guard now.timeIntervalSince(self.lastPipelineRunTime) >= self.minimumUpdateInterval else {
                self.currentCoordinate = coordinate
                return
            }
            self.lastPipelineRunTime = now
            self.currentCoordinate   = coordinate
            await self.runPipeline(coordinate: coordinate)
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Silently retain last known coordinate — pipeline uses cached data
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            let status = manager.authorizationStatus
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                self.manager.startUpdatingLocation()
            }
        }
    }
}
