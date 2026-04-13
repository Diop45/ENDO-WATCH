import SwiftUI

/// Primary watch screen: proximity strip (fed later by companion / location).
struct WatchRootView: View {
    /// Placeholder until WatchConnectivity or HealthKit-driven target distance exists.
    @State private var proximity01: Double = 0.62
    @State private var distanceMeters: Double = 240

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Proximity")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
            ProximitySegmentBar(
                progress01: proximity01,
                distanceMeters: distanceMeters)
            Text("ENDO")
                .font(.system(size: 15, weight: .bold))
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 8)
        .padding(.top, 4)
    }
}

#Preview {
    WatchRootView()
}
