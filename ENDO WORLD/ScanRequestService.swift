import CoreLocation
import Foundation
import SwiftUI

/// Manages scan request lifecycle between anonymous users.
/// Demo: mocked state machine.
@Observable @MainActor
final class ScanRequestService {

    var pendingOutgoing: [String: AnonUser] = [:]
    var pendingIncoming: [String: AnonUser] = [:]
    var activeSessions: [String: SharedScanSession] = [:]

    var totalMutualScans: Int = 0

    var isMapperUnlocked: Bool {
        totalMutualScans >= 10
    }

    func registerActiveSession(_ session: SharedScanSession) {
        activeSessions[session.id] = session
    }

    func sendRequest(
        to user: AnonUser,
        ourZone: ZoneClassification,
        ourLens: NodeLens,
        completion: @escaping (Bool) -> Void
    ) {
        pendingOutgoing[user.id] = user

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 2.0
        ) { [weak self] in
            guard let self else { return }
            let accepted = Double.random(in: 0 ... 1) > 0.30
            self.pendingOutgoing.removeValue(forKey: user.id)
            completion(accepted)
        }
    }

    func acceptRequest(
        from user: AnonUser,
        atCoordinate: CLLocationCoordinate2D
    ) -> SharedScanSession {
        pendingIncoming.removeValue(forKey: user.id)
        let session = SharedScanSession(
            id: UUID().uuidString,
            partnerUserId: user.id,
            coordinate: atCoordinate)
        activeSessions[session.id] = session
        return session
    }

    func ignoreRequest(from userId: String) {
        pendingIncoming.removeValue(forKey: userId)
    }

    func registerPendingIncoming(_ user: AnonUser) {
        pendingIncoming[user.id] = user
    }

    func completeSession(
        _ sessionId: String,
        wasHostileZone: Bool
    ) -> Int {
        activeSessions.removeValue(forKey: sessionId)
        totalMutualScans += 1
        let baseXP = wasHostileZone ? 25 : 10
        let earned = Int(Double(baseXP) * 1.5)
        return earned
    }
}
