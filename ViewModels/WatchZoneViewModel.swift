import Foundation
import CoreLocation
import MapKit

@Observable
@MainActor
class WatchZoneViewModel {

    // MARK: - New pipeline services

    let streamService  = BiometricStreamService()
    let dataStore      = MapDataStore()
    let shareService   = AnonymousShareService()

    private let liveDataService = LiveDataService()
    private let fusionEngine    = ZoneFusionEngine()
    private(set) var locationService: LocationService

    // MARK: - Legacy motion service (activity icon)

    let motion = WatchMotionService()

    // MARK: - Map state

    var cameraPosition: MapCameraPosition = .automatic

    private(set) var userCoordinate = CLLocationCoordinate2D(
        latitude: 42.3314,
        longitude: -83.0458
    )

    // MARK: - Init

    init() {
        let live    = liveDataService
        let fusion  = fusionEngine
        let store   = dataStore
        let share   = shareService
        locationService = LocationService(
            liveDataService: live,
            fusionEngine: fusion,
            dataStore: store,
            shareService: share
        )
        locationService.streamService = streamService
    }

    // MARK: - Computed bridge properties (used by WatchMapView, WatchZoneCompassView)

    var currentZone: ZoneClassification {
        dataStore.personalPin?.zone ?? .moderate
    }

    var zoneColor: Color { currentZone.color }

    var compositeScore: Int { dataStore.personalPin?.compositeScore ?? 0 }

    var dominantSignal: String { dataStore.personalPin?.dominantSignal ?? "Heart Rate" }

    // Live biometrics from stream
    var heartRate: Double  { streamService.heartRate }
    var hrv: Double        { streamService.hrv }
    var noiseLevel: Double { streamService.noiseLevel }

    // Environmental from latest pipeline run
    var aqi: Int { locationService.latestEnvironmental?.aqi ?? 0 }

    var activityIconName: String {
        motion.iconName(for: motion.currentActivity)
    }

    // Computed BiometricReading for legacy WatchHUDView compatibility
    var currentBiometric: BiometricReading {
        BiometricReading(
            heartRate:       streamService.heartRate,
            hrv:             streamService.hrv,
            spo2:            streamService.spo2,
            respiratoryRate: streamService.respiratoryRate,
            timestamp:       streamService.lastUpdated,
            source:          .appleWatch
        )
    }

    // MARK: - Lifecycle

    func start() async {
        motion.start()
        streamService.startStreaming()
        locationService.startTracking()
        centerCamera()

        // Start neighborhood pin refresh loop
        dataStore.startNeighborhoodRefresh(coordinate: userCoordinate)

        // Run initial pipeline pass with Detroit default if location not yet available
        await locationService.runPipeline(coordinate: userCoordinate)
    }

    func stop() {
        motion.stop()
        streamService.stopStreaming()
        locationService.stopTracking()
        dataStore.stopNeighborhoodRefresh()
    }

    // MARK: - Camera

    private func centerCamera() {
        let coord = locationService.currentCoordinate ?? userCoordinate
        cameraPosition = .region(
            MKCoordinateRegion(
                center: coord,
                latitudinalMeters: 3200,
                longitudinalMeters: 3200
            )
        )
    }
}
