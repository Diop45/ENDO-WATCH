import SwiftUI

/// watchOS-only: 15-segment proximity strip (condition / user distance from iPhone companion).
struct ProximitySegmentBar: View {
    var progress01: Double
    var distanceMeters: Double?

    private let segmentCount = 15
    private let segmentSpacing: CGFloat = 2
    private let segmentHeight: CGFloat = 16
    private let segmentCorner: CGFloat = 3

    private var litSegments: Int {
        let raw = progress01 * Double(segmentCount)
        return max(
            0,
            min(
                segmentCount,
                Int((raw).rounded(.toNearestOrAwayFromZero))))
    }

    var body: some View {
        HStack(spacing: segmentSpacing) {
            ForEach(0 ..< segmentCount, id: \.self) { i in
                RoundedRectangle(
                    cornerRadius: segmentCorner,
                    style: .continuous)
                    .fill(segmentColor(index: i))
                    .frame(height: segmentHeight)
                    .frame(maxWidth: .infinity)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private func segmentColor(index i: Int) -> Color {
        guard i < litSegments else {
            return Color(red: 0.16, green: 0.16, blue: 0.18)
        }
        let u = Double(i) / Double(max(segmentCount - 1, 1))
        if u < 0.27 {
            return Color(red: 0.22, green: 0.78, blue: 1.0)
        }
        if u < 0.36 {
            return Color(red: 0.24, green: 0.79, blue: 0.66)
        }
        return Color(red: 0.55, green: 0.92, blue: 0.35)
    }

    private var accessibilityText: String {
        let pct = Int((progress01 * 100).rounded())
        if let d = distanceMeters {
            let dist: String
            if d >= 1609 {
                dist = String(format: "%.1f miles away", d / 1609)
            } else if d >= 100 {
                dist = "\(Int(d)) meters away"
            } else {
                dist = "\(Int(d * 3.281)) feet away"
            }
            return "Proximity \(pct) percent. \(dist)"
        }
        return "Proximity \(pct) percent"
    }
}
