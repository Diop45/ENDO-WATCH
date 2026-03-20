import SwiftUI

// MARK: - City light positions (deterministic — no random in render path)
// Roughly approximates North America, Europe, and East Asia city clusters.

private let cityLightPositions: [(Double, Double)] = [
    // North America east coast
    (0.36, 0.38), (0.38, 0.36), (0.40, 0.34), (0.42, 0.37), (0.39, 0.41),
    (0.37, 0.44), (0.41, 0.40), (0.35, 0.46), (0.43, 0.33),
    // North America midwest / central
    (0.32, 0.40), (0.30, 0.43), (0.33, 0.47), (0.31, 0.50),
    // Europe
    (0.57, 0.30), (0.59, 0.28), (0.61, 0.32), (0.55, 0.33), (0.63, 0.29),
    (0.58, 0.35), (0.60, 0.26), (0.56, 0.27),
    // East Asia
    (0.74, 0.32), (0.76, 0.30), (0.78, 0.35), (0.72, 0.36), (0.75, 0.38),
    (0.79, 0.29), (0.77, 0.40),
    // Southeast Asia
    (0.74, 0.50), (0.76, 0.52), (0.72, 0.48),
    // Middle East
    (0.63, 0.41), (0.65, 0.39), (0.67, 0.42),
    // South America
    (0.40, 0.62), (0.42, 0.58), (0.38, 0.65), (0.41, 0.55),
    // Africa
    (0.56, 0.52), (0.58, 0.55), (0.60, 0.50),
    // Australia
    (0.80, 0.62), (0.82, 0.65), (0.78, 0.64),
]

private let cityLightBrightness: [Double] = [
    0.8, 0.6, 0.9, 0.5, 0.7, 0.85, 0.6, 0.75, 0.5,
    0.7, 0.55, 0.8, 0.65, 0.9, 0.7, 0.8, 0.6, 0.85,
    0.5, 0.75, 0.9, 0.6, 0.85, 0.7, 0.55, 0.9, 0.65,
    0.8, 0.5, 0.7, 0.6, 0.75, 0.8, 0.55, 0.7, 0.6,
    0.9, 0.65, 0.5, 0.8, 0.7, 0.6, 0.5, 0.85, 0.6,
    0.7, 0.8, 0.55, 0.65, 0.9,
]

// MARK: - WatchLocationLockView

struct WatchLocationLockView: View {

    let onDismiss: () -> Void

    @State private var isPulsing    = false
    @State private var loadProgress = 0.08
    @State private var statusText   = "Updating Location"
    @State private var globeScale   = 1.0
    @State private var globeOpacity = 1.0
    @State private var scanAngle    = 0.0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()

                globeLayer(geo: geo)
                    .scaleEffect(globeScale)
                    .opacity(globeOpacity)

                topChrome
                    .opacity(globeOpacity)

                bottomStatus
                    .opacity(globeOpacity)
            }
        }
        .ignoresSafeArea()
        .onAppear { isPulsing = true }
        .task { await runLoadSequence() }
    }

    // MARK: - Globe

    @ViewBuilder
    private func globeLayer(geo: GeometryProxy) -> some View {
        let W = geo.size.width
        let H = geo.size.height
        // Globe radius much larger than screen — only the top cap is visible.
        // This makes the horizon curve match the screenshot.
        let R = W * 1.30
        // Position globe center so its top edge (horizon) sits at ~37% screen height.
        let centerY = H * 0.37 + R

        ZStack {
            // Globe body — deep navy nightside
            Circle()
                .fill(
                    RadialGradient(
                        stops: [
                            .init(color: Color(hex: "#0B1827"), location: 0.0),
                            .init(color: Color(hex: "#0D1E30"), location: 0.55),
                            .init(color: Color(hex: "#0A1520"), location: 1.0)
                        ],
                        center: UnitPoint(x: 0.45, y: 0.35),
                        startRadius: 0,
                        endRadius: R
                    )
                )
                .frame(width: R * 2, height: R * 2)

            // Earth texture (earth_night asset or fallback)
            ZStack {
                Canvas { context, size in
                    var path = Path()
                    let points: [(Double, Double)] = [
                        (0.25, 0.35), (0.35, 0.30), (0.42, 0.32), (0.45, 0.38),
                        (0.42, 0.48), (0.35, 0.52), (0.28, 0.50), (0.22, 0.42)
                    ]
                    if let first = points.first {
                        path.move(to: CGPoint(x: first.0 * size.width, y: first.1 * size.height))
                        for p in points.dropFirst() {
                            path.addLine(to: CGPoint(x: p.0 * size.width, y: p.1 * size.height))
                        }
                        path.closeSubpath()
                    }
                    context.fill(path, with: .color(Color(hex: "#0D2A3A").opacity(0.6)))
                }
                Image("earth_night")
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .opacity(0.82)
            }
            .frame(width: R * 2, height: R * 2)
            .clipShape(Circle())

            // City lights
            Canvas { context, size in
                let count = min(cityLightPositions.count, cityLightBrightness.count)
                for i in 0..<count {
                    let (nx, ny) = cityLightPositions[i]
                    let brightness = cityLightBrightness[i]
                    let x = nx * size.width
                    let y = ny * size.height
                    let r: CGFloat = brightness > 0.75 ? 1.5 : 1.0
                    context.fill(
                        Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                        with: .color(
                            Color(red: 1.0, green: 0.88, blue: 0.45).opacity(brightness * 0.9)
                        )
                    )
                }
            }
            .frame(width: R * 2, height: R * 2)
            .clipShape(Circle())

            // Atmospheric rim glow — bright cyan halo at the edge
            Circle()
                .fill(
                    RadialGradient(
                        stops: [
                            .init(color: .clear,                              location: 0.82),
                            .init(color: Color(hex: "#00C8F0").opacity(0.55), location: 0.92),
                            .init(color: Color(hex: "#0090B8").opacity(0.30), location: 0.97),
                            .init(color: .clear,                              location: 1.00)
                        ],
                        center: .center,
                        startRadius: R * 0.80,
                        endRadius: R
                    )
                )
                .frame(width: R * 2, height: R * 2)

            // Terminator gradient — slightly lighter on one side (day/night boundary)
            Circle()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: "#1A3A4A").opacity(0.25), location: 0.0),
                            .init(color: .clear, location: 0.5)
                        ],
                        startPoint: UnitPoint(x: 0.75, y: 0.2),
                        endPoint: UnitPoint(x: 0.3,  y: 0.7)
                    )
                )
                .frame(width: R * 2, height: R * 2)

            // User dot center: -R*0.05 x, -R*0.85 y (center of globe cap)
            let dotOffsetX = -R * 0.05
            let dotOffsetY = -(R * 0.85)

            // GPS icon — 28pt above user dot
            Image(systemName: "dot.radiowaves.left.and.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
                .symbolEffect(.variableColor.iterative, options: .repeating)
                .offset(x: dotOffsetX, y: dotOffsetY - 28)

            // Active scan ring
            Circle()
                .trim(from: 0, to: 0.25)
                .stroke(
                    Color(hex: "#34C759").opacity(0.4),
                    style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [2, 4])
                )
                .frame(width: 52, height: 52)
                .rotationEffect(.degrees(scanAngle))
                .offset(x: dotOffsetX, y: dotOffsetY)
                .animation(.linear(duration: 3).repeatForever(autoreverses: false), value: scanAngle)

            // User location dot
            userLocationDot
                .offset(x: dotOffsetX, y: dotOffsetY)
        }
        .position(x: W / 2, y: centerY)
    }

    private var userLocationDot: some View {
        ZStack {
            // Outer pulse ring
            Circle()
                .fill(Color(hex: "#34C759").opacity(0.25))
                .frame(width: 34, height: 34)
                .scaleEffect(isPulsing ? 1.45 : 1.0)
                .animation(
                    .easeInOut(duration: 1.3).repeatForever(autoreverses: true),
                    value: isPulsing
                )
            // Inner filled dot with white border
            Circle()
                .fill(Color(hex: "#34C759"))
                .frame(width: 20, height: 20)
                .overlay(
                    Circle().strokeBorder(.white, lineWidth: 2.5)
                )
        }
    }

    // MARK: - Top chrome

    private var topChrome: some View {
        ZStack {
            // Time — top right
            Text(Date(), style: .time)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 10)
                .padding(.top, 8)

            // Dismiss — top left
            Button(action: triggerZoomAndDismiss) {
                ZStack {
                    Circle()
                        .fill(Color(white: 0.18).opacity(0.9))
                        .frame(width: 32, height: 32)
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 8)
            .padding(.top, 6)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Bottom status

    private var bottomStatus: some View {
        VStack(spacing: 8) {
            Text(statusText)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .animation(.easeInOut(duration: 0.3), value: statusText)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(.white.opacity(0.22))
                        .frame(height: 2.5)
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(.white.opacity(0.75))
                        .frame(width: geo.size.width * loadProgress, height: 2.5)
                        .animation(.easeInOut(duration: 0.5), value: loadProgress)
                }
            }
            .frame(height: 2.5)
            .padding(.horizontal, 32)
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 14)
    }

    // MARK: - Zoom transition (zooms into the Earth toward the user's pin)

    private func triggerZoomAndDismiss() {
        withAnimation(.easeIn(duration: 0.7)) {
            globeScale   = 7.0
            globeOpacity = 0.0
        }
        Task {
            try? await Task.sleep(nanoseconds: 650_000_000)
            onDismiss()
        }
    }

    // MARK: - Load sequence

    private func runLoadSequence() async {
        scanAngle = 360 // triggers the rotation animation

        let steps: [(Double, String, UInt64)] = [
            (0.22, "Updating Location",   800_000_000),
            (0.45, "Reading Air Quality", 1_200_000_000),
            (0.70, "Checking Biometrics", 1_200_000_000),
            (0.90, "Classifying Zone",    1_100_000_000),
            (1.00, "Zone Ready",            700_000_000)
        ]
        for (progress, status, delay) in steps {
            loadProgress = progress
            statusText   = status
            try? await Task.sleep(nanoseconds: delay)
        }
        triggerZoomAndDismiss()
    }
}
