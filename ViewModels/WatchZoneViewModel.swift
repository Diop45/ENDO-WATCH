import Foundation
import CoreLocation
import HealthKit
import MapKit

@Observable
class WatchZoneViewModel {

    // MARK: - Published State

    var currentZone: ZoneClassification = .moderate
    var zonePins: [ZonePin] = []
    var currentBiometric: BiometricReading = .mock
    var currentEnvironmental: EnvironmentalReading = .mock
    var cameraPosition: MapCameraPosition = .automatic

    // MARK: - Services

    let healthKit = WatchHealthKitService()
    let motion    = WatchMotionService()

    private let classifier = ZoneClassifierService()

    // Detroit center — replaced with live location when CoreLocation is wired in
    private(set) var userCoordinate = CLLocationCoordinate2D(
        latitude: 42.3314,
        longitude: -83.0458
    )

    // MARK: - Computed

    var activityIconName: String {
        motion.iconName(for: motion.currentActivity)
    }

    // MARK: - Lifecycle

    func start() async {
        await healthKit.requestAuthorization()
        motion.start()
        seedMockZonePins()
        centerCamera()
        reclassify()
    }

    func stop() {
        motion.stop()
    }

    // MARK: - Classification

    func reclassify() {
        if healthKit.isAuthorized {
            currentBiometric = healthKit.latestReading
        }
        currentZone = classifier.classifyZone(
            biometric: currentBiometric,
            environmental: currentEnvironmental
        )
    }

    // MARK: - Camera

    private func centerCamera() {
        cameraPosition = .region(
            MKCoordinateRegion(
                center: userCoordinate,
                latitudinalMeters: 3200,
                longitudinalMeters: 3200
            )
        )
    }

    // MARK: - Mock Data (Detroit block-level zone pins)

    private func seedMockZonePins() {
        zonePins = [
            ZonePin(
                coordinate: CLLocationCoordinate2D(latitude: 42.338, longitude: -83.052),
                classification: .hostile,
                environmentalScore: 0.72,
                biometricScore: 0.61
            ),
            ZonePin(
                coordinate: CLLocationCoordinate2D(latitude: 42.327, longitude: -83.038),
                classification: .moderate,
                environmentalScore: 0.44,
                biometricScore: 0.38
            ),
            ZonePin(
                coordinate: CLLocationCoordinate2D(latitude: 42.318, longitude: -83.055),
                classification: .supportive,
                environmentalScore: 0.18,
                biometricScore: 0.22
            ),
            ZonePin(
                coordinate: CLLocationCoordinate2D(latitude: 42.342, longitude: -83.041),
                classification: .hostile,
                environmentalScore: 0.81,
                biometricScore: 0.55
            ),
            ZonePin(
                coordinate: CLLocationCoordinate2D(latitude: 42.324, longitude: -83.048),
                classification: .supportive,
                environmentalScore: 0.22,
                biometricScore: 0.19
            ),
            ZonePin(
                coordinate: CLLocationCoordinate2D(latitude: 42.333, longitude: -83.062),
                classification: .moderate,
                environmentalScore: 0.51,
                biometricScore: 0.41
            )
        ]
    }
}
