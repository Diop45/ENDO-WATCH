import CoreLocation
import Foundation
import MapKit

/// Simulates user movement along a route
/// for demo purposes.
/// In production: replace with
/// CLLocationManager delegate callbacks.
@Observable @MainActor
final class LocationSimulator {

    var currentLocation: CLLocationCoordinate2D =
        CLLocationCoordinate2D(
            latitude: 42.3314,
            longitude: -83.0458)

    private(set) var routeCoords: [CLLocationCoordinate2D] = []
    private var coordIndex: Int = 0
    var isRunning: Bool = false

    var routeProgressFraction: Double {
        guard routeCoords.count > 1 else { return 0 }
        let denom = Double(routeCoords.count - 1)
        return min(1, Double(coordIndex) / denom)
    }

    func startSimulation(along polyline: MKPolyline) {
        stopSimulation()
        var coords = [CLLocationCoordinate2D](
            repeating: kCLLocationCoordinate2DInvalid,
            count: polyline.pointCount)
        guard polyline.pointCount > 0 else {
            isRunning = false
            return
        }
        polyline.getCoordinates(
            &coords,
            range: NSRange(
                location: 0,
                length: polyline.pointCount))
        let filtered = coords.filter {
            $0.latitude.isFinite && $0.longitude.isFinite
        }
        routeCoords = filtered
        guard let first = routeCoords.first else {
            isRunning = false
            return
        }
        coordIndex = 0
        currentLocation = first
        isRunning = true
    }

    func stopSimulation() {
        isRunning = false
        routeCoords = []
        coordIndex = 0
    }

    func advance() {
        guard coordIndex + 1 < routeCoords.count else {
            stopSimulation()
            return
        }
        coordIndex += 1
        currentLocation = routeCoords[coordIndex]
    }
}
