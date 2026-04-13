import SwiftUI

/// Top-row metric chips matching the wireframe (HR / HRV / SpO₂ / RR labels).
struct WireframeMetricPillsRow: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        HStack(spacing: 6) {
            pill("HR", value: appState.hr)
            pill("HRV", value: appState.hrv)
            pill("SpO₂", value: appState.spo2)
            pill("RR", value: appState.rr)
        }
    }

    private func pill(
        _ label: String,
        value: Double
    ) -> some View {
        Text(label)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white.opacity(0.72))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.bgSurface)
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(
                    Color.endoCyan.opacity(0.35),
                    lineWidth: 0.5))
            .accessibilityLabel(
                "\(label), \(Int(value.rounded()))")
    }
}

#Preview {
    WireframeMetricPillsRow()
        .environment(AppState())
        .padding()
        .background(Color.bgPrimary)
}
