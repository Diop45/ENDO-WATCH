import CoreLocation
import Foundation
import SwiftUI

struct AnonUser: Identifiable {
    let id: String
    var coordinate: CLLocationCoordinate2D
    var state: AnonUserState
    var zoneSignal: AnonZoneSignal
    var activeLens: NodeLens
    var role: AnonUserRole
    var mutualScanCount: Int = 0
    var distanceMeters: Double = 0

    var proximityBand: AnonProximityBand {
        switch distanceMeters {
        case ..<150: return .close
        case ..<500: return .near
        default: return .distant
        }
    }

    /// Opacity scales with distance to the one-mile edge.
    var dotOpacity: Double {
        let clamped = min(
            distanceMeters,
            anonDetectionRadius)
        let ratio = clamped / anonDetectionRadius
        return 1.0 - (ratio * 0.65)
    }

    var dotSize: CGFloat {
        switch proximityBand {
        case .close: return 32
        case .near: return 28
        case .distant: return 24
        }
    }

    var isVisible: Bool {
        state != .outsideRadius
    }

    var requestCardTitle: String {
        role.isMapper
            ? "ENDO Mapper nearby"
            : "ENDO user nearby"
    }

    /// Environmental context first: distance, then zone. Lens appears separately in UI.
    var requestCardSubtitle: String {
        let zoneText: String
        switch zoneSignal {
        case .hostile: zoneText = "Hostile zone"
        case .moderate: zoneText = "Moderate zone"
        case .supportive: zoneText = "Clean zone"
        case .unknown: zoneText = "Scanning..."
        }
        let distText = formattedDistance
        return "\(distText) away · \(zoneText)"
    }

    var formattedDistance: String {
        if distanceMeters >= 1609 {
            return "1.0mi"
        } else if distanceMeters >= 100 {
            let feet = Int(distanceMeters * 3.281)
            let rounded = (feet / 100) * 100
            return "\(rounded)ft"
        } else {
            let feet = Int(distanceMeters * 3.281)
            return "\(feet)ft"
        }
    }
}
