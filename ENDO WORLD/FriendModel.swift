import CoreLocation
import Foundation
import SwiftUI

struct ENDOFriend: Identifiable {
    let id: String
    var displayName: String
    var initials: String
    var coordinate: CLLocationCoordinate2D
    var zone: ZoneClassification
    var score: Int
    var lastSeen: Date
    var color: Color
    var isInDanger: Bool { zone == .hostile }

    var zoneText: String {
        switch zone {
        case .supportive: "In clean zone"
        case .moderate: "Moderate zone"
        case .hostile: "In hostile zone"
        }
    }
}
