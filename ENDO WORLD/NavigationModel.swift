import CoreLocation
import Foundation
import MapKit
import SwiftUI

enum NavDestinationType {
    case zone(HealthNode)
    case friend(ENDOFriend)
}

enum NavState {
    case idle
    case active
    case nearby
    case arrived
}

struct NavStep: Identifiable {
    let id = UUID()
    let instruction: String
    let distance: Double
    let polylineCoords: [CLLocationCoordinate2D]
}

@Observable @MainActor
final class NavigationModel {

    var state: NavState = .idle
    var destination: NavDestinationType?
    var route: MKRoute?
    var polyline: MKPolyline?
    var steps: [NavStep] = []
    var currentStepIndex: Int = 0
    var distanceToNextStep: Double = 0
    var distanceToDestination: Double = 0
    var etaMinutes: Int = 0
    var instruction: String = ""
    var directionAngle: Double = 0
    var isCalculating: Bool = false
    var error: String?

    var simulatedProgress: Double = 0

    var isActive: Bool {
        state != .idle
    }

    var destinationNode: HealthNode? {
        guard case let .zone(n) = destination else { return nil }
        return n
    }

    var destinationFriend: ENDOFriend? {
        guard case let .friend(f) = destination else { return nil }
        return f
    }

    var destinationCoordinate: CLLocationCoordinate2D? {
        switch destination {
        case let .zone(n):
            return n.coordinate
        case let .friend(f):
            return f.coordinate
        case nil:
            return nil
        }
    }

    var destinationTitle: String {
        switch destination {
        case let .zone(n): return n.title
        case let .friend(f): return f.displayName
        case nil: return ""
        }
    }

    var destinationSubtitle: String {
        switch destination {
        case let .zone(n): return n.subtitle
        case let .friend(f): return f.zoneText
        case nil: return ""
        }
    }

    var destinationColor: Color {
        switch destination {
        case let .zone(n):
            return n.primaryLens.color
        case let .friend(f):
            return f.color
        case nil:
            return .endoCyan
        }
    }

    var destinationMetricValue: String {
        switch destination {
        case let .zone(n):
            return n.envMetricValue
        case let .friend(f):
            return "\(f.score)"
        case nil:
            return ""
        }
    }

    var destinationMetricLabel: String {
        switch destination {
        case let .zone(n):
            return n.envMetricLabel
        case .friend:
            return "Zone score"
        case nil:
            return ""
        }
    }

    var destinationMetricColor: Color {
        switch destination {
        case let .zone(n):
            return n.envMetricColor
        case let .friend(f):
            return f.color
        case nil:
            return .endoCyan
        }
    }

    var proximityNote: String {
        switch state {
        case .idle:
            return ""
        case .active:
            switch destination {
            case .zone:
                return "Route avoids hostile nodes"
            case let .friend(f):
                return "Getting closer to \(f.displayName)..."
            case nil:
                return ""
            }
        case .nearby:
            switch destination {
            case let .zone(n):
                return "Entering \(n.title)..."
            case let .friend(f):
                return "\(f.displayName) is 150ft away"
            case nil:
                return ""
            }
        case .arrived:
            switch destination {
            case let .zone(n):
                return "You are in \(n.title)"
            case let .friend(f):
                return "You found \(f.displayName)"
            case nil:
                return ""
            }
        }
    }

    func startNavigation(
        to dest: NavDestinationType,
        from origin: CLLocationCoordinate2D
    ) async {
        isCalculating = true
        error = nil
        destination = dest

        guard let coord = destinationCoordinate else {
            isCalculating = false
            return
        }

        let req = MKDirections.Request()
        req.source = MKMapItem(
            placemark: MKPlacemark(coordinate: origin))
        req.destination = MKMapItem(
            placemark: MKPlacemark(coordinate: coord))
        req.transportType = .walking
        req.requestsAlternateRoutes = false

        do {
            let response = try await MKDirections(request: req)
                .calculate()
            guard let r = response.routes.first else {
                error = "No route found"
                isCalculating = false
                return
            }

            route = r
            polyline = r.polyline
            etaMinutes = Int(r.expectedTravelTime / 60)
            distanceToDestination = r.distance

            steps = r.steps.map { step in
                NavStep(
                    instruction: step.instructions.isEmpty
                        ? "Continue"
                        : step.instructions,
                    distance: step.distance,
                    polylineCoords: extractCoords(step.polyline))
            }

            currentStepIndex = 0
            syncStepIndex(forRemaining: r.distance)
            updateInstruction()
            state = .active
            isCalculating = false

        } catch {
            self.error = "Route unavailable"
            isCalculating = false
            destination = nil
        }
    }

    func endNavigation() {
        state = .idle
        destination = nil
        route = nil
        polyline = nil
        steps = []
        currentStepIndex = 0
        distanceToDestination = 0
        distanceToNextStep = 0
        instruction = ""
        directionAngle = 0
        simulatedProgress = 0
        isCalculating = false
        error = nil
    }

    func updateDistance(_ distance: Double) {
        distanceToDestination = distance
        syncStepIndex(forRemaining: distance)
        switch distance {
        case ..<20:
            if state != .arrived {
                state = .arrived
                instruction = "Arrived."
            }
        case ..<150:
            if state == .active {
                state = .nearby
                updateInstruction()
            }
        default:
            if state == .nearby {
                state = .active
            }
            updateInstruction()
        }
    }

    func advanceSimulation(by delta: Double) {
        guard state == .active || state == .nearby else { return }
        simulatedProgress = min(1.0, simulatedProgress + delta)
        let totalDist = route?.distance ?? 500
        let remaining = totalDist * (1 - simulatedProgress)
        updateDistance(remaining)
    }

    func updateRouteProgress(_ fraction: Double) {
        guard let r = route, !steps.isEmpty else { return }
        let traveled = fraction * r.distance
        var cum: Double = 0
        var idx = 0
        for i in steps.indices {
            cum += steps[i].distance
            if traveled < cum {
                idx = i
                break
            }
            idx = i
        }
        currentStepIndex = min(idx, steps.count - 1)
        updateInstruction()
    }

    func updateFacing(
        from user: CLLocationCoordinate2D,
        simulatorFraction: Double
    ) {
        guard let dest = destinationCoordinate else {
            directionAngle = 0
            return
        }
        if let route,
           let poly = polyline,
           poly.pointCount > 1
        {
            var coords = [CLLocationCoordinate2D](
                repeating: kCLLocationCoordinate2DInvalid,
                count: poly.pointCount)
            poly.getCoordinates(
                &coords,
                range: NSRange(
                    location: 0,
                    length: poly.pointCount))
            let valid = coords.filter {
                $0.latitude.isFinite && $0.longitude.isFinite
            }
            if valid.count > 1 {
                let maxI = valid.count - 1
                let targetIndex = min(
                    maxI,
                    max(1, Int(simulatorFraction * Double(maxI))))
                let target = valid[targetIndex]
                directionAngle = bearingDegrees(
                    from: user,
                    to: target)
                return
            }
        }
        directionAngle = bearingDegrees(from: user, to: dest)
    }

    private func syncStepIndex(forRemaining remaining: Double) {
        guard let r = route, !steps.isEmpty else { return }
        let traveled = max(0, r.distance - remaining)
        var cum: Double = 0
        var idx = 0
        for i in steps.indices {
            cum += steps[i].distance
            if traveled < cum {
                idx = i
                break
            }
            idx = i
        }
        currentStepIndex = min(idx, steps.count - 1)
    }

    private func updateInstruction() {
        guard !steps.isEmpty else {
            instruction = "Head to destination"
            return
        }
        let idx = min(currentStepIndex, steps.count - 1)
        let step = steps[idx]

        switch state {
        case .active:
            instruction = step.instruction.isEmpty
                ? "Continue"
                : step.instruction
            distanceToNextStep = step.distance
        case .nearby:
            instruction = "Entering \(destinationTitle)."
        case .arrived:
            instruction = "Arrived."
        case .idle:
            instruction = ""
        }
    }
}

private func extractCoords(
    _ polyline: MKPolyline
) -> [CLLocationCoordinate2D] {
    var coords = [CLLocationCoordinate2D](
        repeating: kCLLocationCoordinate2DInvalid,
        count: polyline.pointCount)
    guard polyline.pointCount > 0 else { return [] }
    polyline.getCoordinates(
        &coords,
        range: NSRange(
            location: 0,
            length: polyline.pointCount))
    return coords.filter {
        $0.latitude.isFinite && $0.longitude.isFinite
    }
}

private func bearingDegrees(
    from: CLLocationCoordinate2D,
    to: CLLocationCoordinate2D
) -> Double {
    let lat1 = from.latitude * .pi / 180
    let lat2 = to.latitude * .pi / 180
    let dLon = (to.longitude - from.longitude) * .pi / 180
    let y = sin(dLon) * cos(lat2)
    let x =
        cos(lat1) * sin(lat2)
        - sin(lat1) * cos(lat2) * cos(dLon)
    var brng = atan2(y, x) * 180 / .pi
    brng = (brng + 360).truncatingRemainder(dividingBy: 360)
    return brng
}
