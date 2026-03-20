import Foundation
import CoreLocation
import MapKit
import WatchKit

// MARK: - Notification

extension Notification.Name {
    static let endoProximityThresholdCrossed = Notification.Name("endoProximityThresholdCrossed")
}

// MARK: - WatchNavigationService

@Observable
@MainActor
class WatchNavigationService {

    enum NavigationIntent {
        case avoid
        case seek
    }

    var activeIntent: NavigationIntent?
    var destinationPin: ENDOZonePin?
    var isNavigating: Bool = false
    var currentInstruction: String = ""
    var distanceToDestination: Double = 0
    var etaMinutes: Int = 0

    private var proximityAlertFired = false
    private var routeUpdateTimer: Timer?
    private var locationProvider: (() -> CLLocationCoordinate2D?)?

    func setLocationProvider(_ provider: @escaping () -> CLLocationCoordinate2D?) {
        locationProvider = provider
    }

    func start(intent: NavigationIntent, destination: ENDOZonePin) {
        activeIntent = intent
        destinationPin = destination
        isNavigating = true
        requestRoute(to: destination.coordinate, intent: intent)
        startDistanceUpdates()
    }

    func stop() {
        activeIntent = nil
        destinationPin = nil
        isNavigating = false
        currentInstruction = ""
        routeUpdateTimer?.invalidate()
        routeUpdateTimer = nil
    }

    func reroute() {
        guard let pin = destinationPin, let intent = activeIntent else { return }
        start(intent: intent, destination: pin)
    }

    private func requestRoute(to coordinate: CLLocationCoordinate2D, intent: NavigationIntent) {
        guard let from = locationProvider?() else {
            currentInstruction = "Calculating…"
            return
        }
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: from))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        request.transportType = .walking

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, _ in
            Task { @MainActor in
                guard let self else { return }
                if let route = response?.routes.first {
                    self.currentInstruction = route.steps.first?.instructions ?? "Head toward destination"
                    self.etaMinutes = Int(route.expectedTravelTime / 60)
                    self.distanceToDestination = route.distance
                } else {
                    self.currentInstruction = "Route unavailable"
                }
            }
        }
    }

    private func startDistanceUpdates() {
        routeUpdateTimer?.invalidate()
        routeUpdateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateDistance()
            }
        }
        routeUpdateTimer?.tolerance = 2.0
        RunLoop.current.add(routeUpdateTimer!, forMode: .common)
    }

    private func updateDistance() {
        guard let dest = destinationPin?.coordinate,
              let from = locationProvider?() else { return }
        let fromLoc = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let destLoc = CLLocation(latitude: dest.latitude, longitude: dest.longitude)
        let dist = fromLoc.distance(from: destLoc)
        let wasAbove = distanceToDestination > ZoneNavigationConstants.thresholdMeters
        distanceToDestination = dist

        if dist <= ZoneNavigationConstants.thresholdMeters {
            if !proximityAlertFired {
                proximityAlertFired = true
                WKInterfaceDevice.current().play(.notification)
                NotificationCenter.default.post(name: .endoProximityThresholdCrossed, object: nil)
            }
        } else {
            proximityAlertFired = false
        }
    }
}
