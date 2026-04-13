import SwiftUI

/// Same control as the map-rail `person.crop.circle.fill` slot (under recenter): tap to expand
/// overlapping biometric pods to the left; friend pins toggle lives inside the cluster when open.
struct ProfileBiometricClusterView: View {
    @Environment(AppState.self) private var appState
    @Binding var friendsVisible: Bool
    @State private var expanded = false

    private let hubSide: CGFloat = 40
    /// Pods stay this size in layout so offsets + container width stay predictable (full circles).
    private let podSize: CGFloat = 44
    private let connectorSize: CGFloat = 14

    private var hubActive: Bool {
        expanded || friendsVisible
    }

    var body: some View {
        HStack(alignment: .top, spacing: expanded ? -16 : 0) {
            ZStack(alignment: .topLeading) {
                connectorDot
                    .offset(x: 36, y: 38)
                connectorDot
                    .offset(x: 52, y: 32)
                connectorDot
                    .offset(x: 48, y: 50)

                biometricPod(
                    title: "Heart rate",
                    icon: "heart.fill",
                    value: "\(Int(appState.hr.rounded()))",
                    suffix: "bpm",
                    accent: hrColor(appState.hr))
                    .offset(x: 10, y: 52)
                biometricPod(
                    title: "HRV",
                    icon: "waveform.path.ecg",
                    value: "\(Int(appState.hrv.rounded()))",
                    suffix: "ms",
                    accent: hrvColor(appState.hrv))
                    .offset(x: 58, y: 16)
                biometricPod(
                    title: "Blood oxygen",
                    icon: "drop.degreesign.fill",
                    value: "\(Int(appState.spo2.rounded()))",
                    suffix: "%",
                    accent: .endoCyan)
                    .offset(x: 64, y: 58)
                biometricPod(
                    title: "Respiratory rate",
                    icon: "lungs.fill",
                    value: String(format: "%.0f", appState.rr),
                    suffix: "/min",
                    accent: .endoGreen)
                    .offset(x: 28, y: 88)

                friendPinsToggle
                    .offset(x: 2, y: 138)
            }
            /// Must cover furthest pod edges + friend row; intrinsic pod width used to exceed 40 and clipped at 112.
            .frame(
                width: expanded ? 138 : 0,
                height: expanded ? 176 : 0)
            .opacity(expanded ? 1 : 0)
            .scaleEffect(expanded ? 1 : 0.2)
            .allowsHitTesting(expanded)

            hubButton
        }
        .animation(
            .spring(response: 0.42, dampingFraction: 0.78),
            value: expanded)
        .fixedSize(horizontal: true, vertical: false)
        .onChange(of: expanded) { _, open in
            guard open else { return }
            Task {
                await appState.refreshAppleHealthData()
            }
        }
    }

    private var hubButton: some View {
        Button {
            withAnimation(
                .spring(
                    response: 0.42,
                    dampingFraction: 0.78))
            {
                expanded.toggle()
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    RoundedRectangle(
                        cornerRadius: 10,
                        style: .continuous)
                        .fill(
                            hubActive
                                ? Color.endoCyan.opacity(0.15)
                                : Color.bgSheet.opacity(0.90))
                    RoundedRectangle(
                        cornerRadius: 10,
                        style: .continuous)
                        .strokeBorder(
                            hubActive
                                ? Color.endoCyan.opacity(0.40)
                                : Color.white.opacity(0.08),
                            lineWidth: 0.5)
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(
                            size: 15,
                            weight: .medium))
                        .foregroundStyle(
                            hubActive
                                ? Color.endoCyan
                                : Color.white
                                    .opacity(0.55))
                }
                .frame(width: hubSide, height: hubSide)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            expanded
                ? "Profile, biometrics open. Tap to close."
                : "Profile and friend pins. Tap to show biometrics.")
    }

    private var friendPinsToggle: some View {
        Button {
            friendsVisible.toggle()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 9, weight: .semibold))
                Text(friendsVisible ? "Pins on" : "Pins off")
                    .font(.system(size: 8, weight: .semibold))
            }
            .foregroundStyle(
                friendsVisible
                    ? Color.endoCyan
                    : Color.white.opacity(0.55))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.bgSheet.opacity(0.92))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(
                        Color.white.opacity(0.10),
                        lineWidth: 0.5))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Friend pins on map")
        .accessibilityValue(friendsVisible ? "On" : "Off")
    }

    private var connectorDot: some View {
        Circle()
            .fill(Color.bgElevated)
            .frame(
                width: connectorSize,
                height: connectorSize)
    }

    private func biometricPod(
        title: String,
        icon: String,
        value: String,
        suffix: String,
        accent: Color
    ) -> some View {
        ZStack {
            Circle()
                .fill(Color.bgElevated)
            Circle()
                .strokeBorder(
                    accent.opacity(0.45),
                    lineWidth: 0.5)
            VStack(spacing: 0) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.92))
                Text(value)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.75)
                    .lineLimit(1)
                Text(suffix)
                    .font(.system(size: 6, weight: .medium))
                    .foregroundStyle(.white.opacity(0.45))
                    .lineLimit(1)
            }
            .padding(.vertical, 3)
        }
        .frame(width: podSize, height: podSize)
        .clipShape(Circle())
        .contentShape(Circle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value) \(suffix)")
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack {
            Spacer()
            ProfileBiometricClusterView(friendsVisible: .constant(false))
                .padding()
        }
    }
    .environment(AppState())
}
