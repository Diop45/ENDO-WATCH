import SwiftUI

// MARK: - ClusterDetailSheet

struct ClusterDetailSheet: View {
    let cluster: ConditionCluster
    @Bindable var viewModel: WatchZoneViewModel
    var onNavigate: (WatchNavigationService.NavigationIntent) -> Void
    var onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10) {
                header
                Divider().background(.white.opacity(0.08))

                Text("Conditions at this location")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
                    .textCase(.uppercase)

                conditionsList

                Divider().background(.white.opacity(0.08))

                Text("Current readings")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
                    .textCase(.uppercase)

                HStack(spacing: 6) {
                    readingBadge("AQI", "\(viewModel.aqi)", color: aqiColor(viewModel.aqi))
                    readingBadge("PM2.5", String(format: "%.1f", viewModel.pm25), color: pm25Color(viewModel.pm25))
                    readingBadge("Noise", "\(Int(viewModel.noiseLevel))dB", color: noiseColor(viewModel.noiseLevel))
                }

                Divider().background(.white.opacity(0.08))

                navigationButtons
            }
            .padding(16)
        }
        .background(Color(hex: "#0A0A0F").ignoresSafeArea())
        .onDisappear { onDismiss() }
    }

    private var header: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(categoryColor(cluster.dominantCategory).opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: categoryIcon(cluster.dominantCategory))
                    .font(.system(size: 15))
                    .foregroundStyle(categoryColor(cluster.dominantCategory))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(cluster.dominantCategory.rawValue)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Text("\(cluster.concentrationScore) reports · " + cluster.dominantZone.rawValue)
                    .font(.system(size: 11))
                    .foregroundStyle(cluster.dominantZone.color)
            }
        }
    }

    private var conditionsList: some View {
        let grouped = Dictionary(grouping: cluster.pins, by: { $0.dominantSignal })
        return ForEach(Array(grouped).sorted(by: { $0.value.count > $1.value.count }), id: \.key) { signal, pins in
            HStack {
                Circle()
                    .fill(signalColor(for: signal))
                    .frame(width: 6, height: 6)
                Text(signal)
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(pins.count) reports")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))
                Text("Score \(avgScore(pins))")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(zoneColorForScore(avgScore(pins)))
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 8)
            .background(signalColor(for: signal).opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var navigationButtons: some View {
        VStack(spacing: 8) {
            Button(action: {
                onNavigate(.avoid)
                dismiss()
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color(hex: "#FF3B3B"))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Avoid this area")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        Text("Route around these conditions")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
                .padding(12)
                .background(Color(hex: "#FF3B3B").opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color(hex: "#FF3B3B").opacity(0.25), lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)

            Button(action: {
                onNavigate(.seek)
                dismiss()
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                        .foregroundStyle(Color(hex: "#00E5FF"))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Go toward")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        Text("Navigate to this zone")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
                .padding(12)
                .background(Color(hex: "#00E5FF").opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color(hex: "#00E5FF").opacity(0.25), lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func readingBadge(_ label: String, _ value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func avgScore(_ pins: [ENDOZonePin]) -> Int {
        guard !pins.isEmpty else { return 0 }
        return pins.map { $0.compositeScore }.reduce(0, +) / pins.count
    }

    private func zoneColorForScore(_ score: Int) -> Color {
        score >= 66 ? Color(hex: "#00E5FF") :
        score >= 35 ? Color(hex: "#FFB800") : Color(hex: "#FF3B3B")
    }

    private func signalColor(for signal: String) -> Color {
        categoryColor(signalToCategory(signal))
    }

    private func aqiColor(_ aqi: Int) -> Color {
        if aqi <= 50 { return Color(hex: "#34C759") }
        if aqi <= 100 { return Color(hex: "#FFB800") }
        return Color(hex: "#FF3B3B")
    }

    private func pm25Color(_ pm25: Double) -> Color {
        if pm25 <= 12 { return Color(hex: "#34C759") }
        if pm25 <= 35.4 { return Color(hex: "#FFB800") }
        return Color(hex: "#FF3B3B")
    }

    private func noiseColor(_ db: Double) -> Color {
        if db <= 55 { return Color(hex: "#34C759") }
        if db <= 70 { return Color(hex: "#FFB800") }
        return Color(hex: "#FF3B3B")
    }
}
