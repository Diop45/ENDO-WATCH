import CoreLocation
import Foundation

/// Identifies H3 cells with multiple node
/// types and consolidates them into compound
/// nodes for map display.
/// In production: uses real H3 indexing.
/// In mock: groups by proximity threshold.
struct CompoundNodeService {

    /// Distance threshold for grouping
    /// nodes into same logical cell
    private static let cellRadius: Double = 120

    private static func mergedProximity(
        for nodes: [HealthNode]
    ) -> NodeProximityState {
        let states = nodes.map(\.proximityState)
        if states.contains(.selected) { return .selected }
        if states.contains(.autoReveal) { return .autoReveal }
        if states.contains(.nearby) { return .nearby }
        if states.contains(.visited) { return .visited }
        return .idle
    }

    static func buildCompoundNodes(
        from nodes: [HealthNode]
    ) -> [CompoundNode] {
        var used = Set<String>()
        var compounds: [CompoundNode] = []

        for node in nodes {
            guard !used.contains(node.id) else {
                continue
            }
            let nearby = nodes.filter { other in
                guard !used.contains(other.id),
                      other.id != node.id
                else { return false }
                return distanceBetween(
                    node.coordinate,
                    other.coordinate) < cellRadius
            }
            guard !nearby.isEmpty else { continue }
            let group = [node] + nearby
            for n in group { used.insert(n.id) }
            let compound = CompoundNode(
                id: "compound_\(node.id)",
                coordinate: node.coordinate,
                constituents: group,
                proximityState: mergedProximity(for: group))
            compounds.append(compound)
        }
        return compounds
    }

    /// Check if a node should display as
    /// standalone or is part of a compound
    static func isInCompound(
        nodeId: String,
        compounds: [CompoundNode]
    ) -> Bool {
        compounds.contains {
            $0.constituents.contains {
                $0.id == nodeId
            }
        }
    }
}
