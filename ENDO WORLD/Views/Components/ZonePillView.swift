import SwiftUI

struct ZonePillView: View {
    let zone: ZoneClassification

    var body: some View {
        Text(zone.rawValue)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(zone.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(zone.color.opacity(0.15))
            .clipShape(Capsule())
    }
}
