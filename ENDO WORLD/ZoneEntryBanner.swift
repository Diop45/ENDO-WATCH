import SwiftUI

struct ZoneEntryBanner: View {
    let zone: ZoneClassification
    let signal: String
    var navActive: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            Text("NOW ENTERING")
                .font(.system(
                    size: 9, weight: .medium))
                .foregroundStyle(
                    .white.opacity(0.40))
                .kerning(1.5)
                .textCase(.uppercase)
            Text(zone.rawValue.uppercased())
                .font(.system(
                    size: 20, weight: .bold))
                .foregroundStyle(zone.color)
            if !signal.isEmpty {
                Text(signal)
                    .font(.system(size: 11))
                    .foregroundStyle(
                        .white.opacity(0.50))
            }
            if navActive {
                Text(navMessage)
                    .font(.system(
                        size: 10, weight: .medium))
                    .foregroundStyle(
                        zone.color.opacity(0.80))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            Color.bgSheet.opacity(0.95))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 12,
                style: .continuous))
        .overlay(
            RoundedRectangle(
                cornerRadius: 12,
                style: .continuous)
                .strokeBorder(
                    zone.color.opacity(0.35),
                    lineWidth: 0.5))
    }

    private var navMessage: String {
        switch zone {
        case .hostile:
            return "Stay on route to exit this zone"
        case .moderate:
            return "Passing through · keep moving"
        case .supportive:
            return "You've reached clean air"
        }
    }
}

#Preview("Hostile") {
    ZoneEntryBanner(
        zone: .hostile,
        signal: "AQI 148")
        .padding()
        .background(Color.bgPrimary)
}

#Preview("Supportive") {
    ZoneEntryBanner(
        zone: .supportive,
        signal: "AQI 22")
        .padding()
        .background(Color.bgPrimary)
}

#Preview("Nav active") {
    ZoneEntryBanner(
        zone: .hostile,
        signal: "AQI 148",
        navActive: true)
        .padding()
        .background(Color.bgPrimary)
}
