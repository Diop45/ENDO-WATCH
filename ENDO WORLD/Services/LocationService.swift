import Foundation
import CoreLocation

@Observable
@MainActor
final class LocationService: NSObject {

    static var shared: LocationService?
    var currentCoordinate: CLLocationCoordinate2D?
    weak var appState: AppState?
    private let manager = CLLocationManager()

    override init() {
        super.init()
        LocationService.shared = self
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func startTracking() {
        manager.startUpdatingLocation()
    }

    func stopTracking() {
        manager.stopUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task { @MainActor in
            currentCoordinate = loc.coordinate
            LocationService.shared?.appState?.userCoordinate = loc.coordinate
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}
