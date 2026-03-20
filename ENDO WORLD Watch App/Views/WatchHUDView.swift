import SwiftUI

/// Screen-anchored HUD overlay — Layer 2 of the watchOS map architecture.
/// Renders time + activity icon at top, zone status + biometrics at bottom.
/// Not geo-anchored. Lives in ZStack above the Map layer.
struct WatchHUDView: View {
    let zone: ZoneClassification
    let biometric: BiometricReading
    let activityIconName: String

    var body: some View {
        VStack {
            topBar
            Spacer()
            bottomBar
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Text(Date.now, format: .dateTime.hour().minute())
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.endoCyan)
                .monospacedDigit()
            Spacer()
            Image(systemName: activityIconName)
                .font(.system(size: 10))
                .foregroundStyle(Color.endoCyan)
        }
        .padding(.horizontal, 10)
        .padding(.top, 6)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: 0) {
            zoneBadge
            Spacer()
            biometricReadout
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 6)
    }

    private var zoneBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(zone.color)
                .frame(width: 5, height: 5)
            Text(zone.label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(zone.color)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(zone.color.opacity(0.15), in: Capsule())
    }

    private var biometricReadout: some View {
        HStack(spacing: 8) {
            Label {
                Text("\(Int(biometric.heartRate))")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white)
            } icon: {
                Image(systemName: "heart.fill")
                    .font(.system(size: 7))
                    .foregroundStyle(Color.endoHostile)
            }

            Label {
                Text("\(Int(biometric.spo2))%")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white)
            } icon: {
                Image(systemName: "lungs.fill")
                    .font(.system(size: 7))
                    .foregroundStyle(Color.endoCyan)
            }
        }
    }
}

#Preview {
    WatchHUDView(
        zone: .hostile,
        biometric: .mock,
        activityIconName: "figure.run"
    )
    .background(Color.endoBackground)
}
