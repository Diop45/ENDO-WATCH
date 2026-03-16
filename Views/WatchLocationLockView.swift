import SwiftUI

// MARK: - WatchLocationLockView
// Modeled on the Find My globe loading screen.
// Shown on first launch and on location refresh until GPS + env data are ready.
// Transitions to WatchMapView automatically after ~4.5 s, or on dismiss tap.

struct WatchLocationLockView: View {

    let onDismiss: () -> Void

    @State private var isPulsing: Bool = false
    @State private var loadProgress: Double = 0.0
    @State private var locationStatus: String = "Scanning Environment"

    var body: some View {
        ZStack {
            background
            centerContent
            timeLabel
            dismissButton
        }
        .onAppear { isPulsing = true }
        .task { await runLoadSequence() }
    }

    // MARK: - Background

    private var background: some View {
        RadialGradient(
            colors: [Color(hex: "#0D2137"), Color(hex: "#0A0A0F")],
            center: UnitPoint(x: 0.5, y: 0.7),
            startRadius: 20,
            endRadius: 160
        )
        .ignoresSafeArea()
    }

    // MARK: - Center content

    private var centerContent: some View {
        VStack(spacing: 16) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(.white.opacity(0.7))
                .symbolEffect(.variableColor.iterative, options: .repeating)

            globeView

            Text(locationStatus)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)

            progressBar
        }
    }

    // MARK: - Globe

    private var globeView: some View {
        ZStack {
            // Atmosphere glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#00E5FF").opacity(0.15), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)

            // Globe body
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#0D2137"), Color(hex: "#1A3A2A")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 90, height: 90)

            // Horizon line
            Ellipse()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color(hex: "#00E5FF").opacity(0.6), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
                .frame(width: 90, height: 20)
                .offset(y: 30)

            // User location dot — pulsing green (Find My inspired)
            userDot
        }
    }

    private var userDot: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "#34C759").opacity(0.3))
                .frame(width: 20, height: 20)
                .scaleEffect(isPulsing ? 1.4 : 1.0)
                .animation(
                    .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                    value: isPulsing
                )
            Circle()
                .fill(Color(hex: "#34C759"))
                .frame(width: 10, height: 10)
        }
        .offset(x: -8, y: 10)
    }

    // MARK: - Progress bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(.white.opacity(0.2))
                    .frame(height: 3)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "#00E5FF"))
                    .frame(width: geo.size.width * loadProgress, height: 3)
                    .animation(.easeInOut(duration: 0.4), value: loadProgress)
            }
        }
        .frame(height: 3)
        .padding(.horizontal, 24)
    }

    // MARK: - Overlaid UI

    private var timeLabel: some View {
        Text(Date(), style: .time)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.white.opacity(0.5))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(8)
    }

    private var dismissButton: some View {
        Button(action: onDismiss) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 28, height: 28)
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(8)
        .buttonStyle(.plain)
    }

    // MARK: - Load sequence

    private func runLoadSequence() async {
        let steps: [(Double, String, UInt64)] = [
            (0.35, "Reading Air Quality",  1_200_000_000),
            (0.65, "Checking Biometrics",  1_200_000_000),
            (0.90, "Classifying Zone",     1_200_000_000),
            (1.00, "Zone Ready",             900_000_000)
        ]
        for (progress, status, delay) in steps {
            loadProgress = progress
            locationStatus = status
            try? await Task.sleep(nanoseconds: delay)
        }
        onDismiss()
    }
}
