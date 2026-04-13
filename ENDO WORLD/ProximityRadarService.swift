import CoreLocation
import Foundation
import SwiftUI

/// Detects other ENDO users within one mile. Separate from public-health node scanning.
@Observable @MainActor
final class ProximityRadarService {

    var detectedUsers: [AnonUser] = []

    private var latestUserLocation: CLLocationCoordinate2D =
        CLLocationCoordinate2D(
            latitude: 42.3314,
            longitude: -83.0458)

    var visibleUsers: [AnonUser] {
        detectedUsers.filter(\.isVisible)
    }

    /// Updates distances and emits enter/exit one-mile events.
    func updateDistances(
        from userLocation: CLLocationCoordinate2D,
        completion: @escaping (
            _ entered: [AnonUser],
            _ exited: [AnonUser]
        ) -> Void
    ) {
        latestUserLocation = userLocation
        var entered: [AnonUser] = []
        var exited: [AnonUser] = []

        for i in detectedUsers.indices {
            let userId = detectedUsers[i].id
            let wasOutside =
                detectedUsers[i].state == .outsideRadius
            let wasInRadius = detectedUsers[i].state
                != .outsideRadius

            let dist = distanceBetween(
                userLocation,
                detectedUsers[i].coordinate)
            detectedUsers[i].distanceMeters = dist

            if dist > anonDetectionRadius {
                if wasInRadius {
                    detectedUsers[i].state = .outsideRadius
                    exited.append(detectedUsers[i])
                }
                continue
            }

            if wasOutside {
                detectedUsers[i].state = .entered
                entered.append(detectedUsers[i])

                let capturedId = userId
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 0.5
                ) { [weak self] in
                    guard let self else { return }
                    guard let j = self.detectedUsers.firstIndex(
                        where: { $0.id == capturedId })
                    else { return }
                    guard self.detectedUsers[j].state == .entered
                    else { return }
                    let dNow = distanceBetween(
                        self.latestUserLocation,
                        self.detectedUsers[j].coordinate)
                    guard dNow <= anonDetectionRadius else { return }
                    self.detectedUsers[j].state = .visible
                }
            }
        }

        if !entered.isEmpty || !exited.isEmpty {
            completion(entered, exited)
        }
    }

    /// Loads mock users around `center` and reconciles distance / visibility.
    func loadMockUsers(
        near center: CLLocationCoordinate2D
    ) {
        detectedUsers = [
            AnonUser(
                id: "anon1",
                coordinate: CLLocationCoordinate2D(
                    latitude: center.latitude + 0.0043,
                    longitude: center.longitude + 0.0021),
                state: .visible,
                zoneSignal: .hostile,
                activeLens: .outcome,
                role: .scout),
            AnonUser(
                id: "anon2",
                coordinate: CLLocationCoordinate2D(
                    latitude: center.latitude - 0.0086,
                    longitude: center.longitude + 0.0043),
                state: .visible,
                zoneSignal: .supportive,
                activeLens: .behavior,
                role: .mapper,
                mutualScanCount: 14),
            AnonUser(
                id: "anon3",
                coordinate: CLLocationCoordinate2D(
                    latitude: center.latitude + 0.0129,
                    longitude: center.longitude - 0.0065),
                state: .visible,
                zoneSignal: .moderate,
                activeLens: .care,
                role: .scout),
            AnonUser(
                id: "anon4",
                coordinate: CLLocationCoordinate2D(
                    latitude: center.latitude - 0.0172,
                    longitude: center.longitude - 0.0086),
                state: .outsideRadius,
                zoneSignal: .hostile,
                activeLens: .outcome,
                role: .scout),
        ]

        for i in detectedUsers.indices {
            let dist = distanceBetween(
                center,
                detectedUsers[i].coordinate)
            detectedUsers[i].distanceMeters = dist
            if dist > anonDetectionRadius {
                detectedUsers[i].state = .outsideRadius
            } else {
                detectedUsers[i].state = .visible
            }
        }
    }

    /// Demo: append a user just outside the radius who can be animated inward.
    func simulateUserEntering(
        near center: CLLocationCoordinate2D
    ) -> AnonUser {
        let zoneOptions: [AnonZoneSignal] = [
            .hostile, .moderate, .supportive,
        ]
        let lensOptions: [NodeLens] = [
            .outcome, .care, .behavior,
        ]
        let newUser = AnonUser(
            id: UUID().uuidString,
            coordinate: CLLocationCoordinate2D(
                latitude: center.latitude + 0.0100,
                longitude: center.longitude + 0.0050),
            state: .outsideRadius,
            zoneSignal: zoneOptions.randomElement()
                ?? .moderate,
            activeLens: lensOptions.randomElement()
                ?? .outcome,
            role: Double.random(in: 0 ... 1) > 0.8
                ? .mapper : .scout,
            distanceMeters: 1650)
        detectedUsers.append(newUser)
        return newUser
    }

    func pruneExitedUsers() {
        detectedUsers.removeAll {
            $0.state == .outsideRadius
                && $0.distanceMeters > anonDetectionRadius
        }
    }
}
