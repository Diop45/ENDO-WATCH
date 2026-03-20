import SwiftUI
import CoreLocation

// MARK: - ProximityWarningView
// Shown when navigating avoid route AND within 500ft of hostile zone.

struct ProximityWarningView: View {
    let pin: ENDOZonePin
    let dominantSignal: String
    @Bindable var navService: WatchNavigationService
    let onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss

    private var distanceMeters: Double { navService.distanceToDestination }

    private var proximityProgress: Double {
        max(0, min(1, 1 - distanceMeters / ZoneNavigationConstants.thresholdMeters))
    }

    private var distanceLabel: String {
        if distanceMeters < 50 { return "\(Int(distanceMeters * 3.281))ft" }
        return "\(Int(distanceMeters * 3.281 / 10) * 10)ft"
    }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    topSection
                    rangeBar
                    bottomSection
                }
                ProximityGauge(progress: proximityProgress, color: Color.endoRed)
            }
            .background(
                VStack(spacing: 0) {
                    Color(hex: "#0A0A0F")
                        .frame(height: geo.size.height * 0.52)
                    Color.endoRed.opacity(0.08 + proximityProgress * 0.17)
                }
            )
        }
        .ignoresSafeArea()
    }

    private var topSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(Color.endoRed)
                Text(Date(), style: .time)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.5))
            }
            HStack(alignment: .bottom) {
                Image(systemName: "figure.walk")
                    .font(.system(size: 28, weight: .thin))
                    .foregroundStyle(.white.opacity(0.55))
                VStack(alignment: .leading, spacing: 2) {
                    Text(distanceLabel)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                    Text("to hostile zone")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.leading, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var rangeBar: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(i < Int(proximityProgress * 5) ? Color.endoRed.opacity(0.3 + Double(i) * 0.15) : Color.white.opacity(0.12))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private var bottomSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HOSTILE ZONE")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.endoRed)
            Text(dominantSignal)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.5))

            if distanceMeters < 50 {
                HStack(spacing: 6) {
                    signalBadge("AQI \(pin.compositeScore)")
                    signalBadge("PM2.5")
                    signalBadge("Noise")
                }
            }

            Button("Reroute") {
                navService.reroute()
                onDismiss()
                dismiss()
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.endoCyan)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)

            Button("Continue anyway") {
                onDismiss()
                dismiss()
            }
            .font(.system(size: 11))
            .foregroundStyle(.white.opacity(0.5))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.endoRed.opacity(0.08 + proximityProgress * 0.17))
    }

    private func signalBadge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .semibold))
            .foregroundStyle(Color.endoRed)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(Color.endoRed.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
