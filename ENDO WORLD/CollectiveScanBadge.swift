import Foundation

/// Collective scan badge metadata for a node.
struct CollectiveScanBadge: Identifiable {
    let id: String
    var defenderCount: Int
    var lastScan: Date

    var badgeText: String {
        defenderCount == 1
            ? "\(defenderCount) defender"
            : "\(defenderCount) defenders"
    }

    var isRecent: Bool {
        Date().timeIntervalSince(lastScan) < 86400
    }
}
