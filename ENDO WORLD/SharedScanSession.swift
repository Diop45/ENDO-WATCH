import CoreLocation
import Foundation

/// Time-bounded shared scan between two anonymous users.
@Observable @MainActor
final class SharedScanSession: Identifiable {
    let id: String
    let partnerUserId: String
    let coordinate: CLLocationCoordinate2D
    let startTime: Date
    var isComplete: Bool = false
    var sharedNodes: [HealthNode] = []
    var xpEarned: Int = 0
    var defenderCount: Int = 2

    var isExpired: Bool {
        Date().timeIntervalSince(startTime) > 300
    }

    var sessionDuration: String {
        let elapsed = Int(
            Date().timeIntervalSince(startTime))
        let remaining = max(0, 300 - elapsed)
        let min = remaining / 60
        let sec = remaining % 60
        return String(
            format: "%d:%02d", min, sec)
    }

    init(
        id: String,
        partnerUserId: String,
        coordinate: CLLocationCoordinate2D
    ) {
        self.id = id
        self.partnerUserId = partnerUserId
        self.coordinate = coordinate
        self.startTime = Date()
    }

    func executeSharedScan(
        existingNodes: [HealthNode]
    ) async -> [HealthNode] {
        let nearby = existingNodes.filter { node in
            distanceBetween(
                coordinate,
                node.coordinate) < 300
        }
        sharedNodes = nearby
        return nearby
    }

    func complete(xp: Int) {
        xpEarned = xp
        isComplete = true
    }
}
