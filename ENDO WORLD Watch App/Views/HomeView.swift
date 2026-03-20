import SwiftUI
import MapKit

// MARK: - HomeView
// First screen after onboarding. Globe background with 3 frosted cards.
// Card 3 opens MapView via NavigationLink.

struct HomeView: View {
    @State private var viewModel = WatchZoneViewModel()
    @State private var selectedSignalsCount = 5

    var body: some View {
        NavigationStack {
            ZStack {
                globeBackground
                contentLayer
            }
            .navigationDestination(for: MapDestination.self) { _ in
                MapView()
                    .environment(viewModel)
            }
            .task { await viewModel.start() }
            .onDisappear { viewModel.stop() }
        }
    }

    // MARK: - Globe background (spec layers)

    private var globeBackground: some View {
        ZStack {
            // Layer 1 — Deep space
            RadialGradient(
                colors: [
                    Color(hex: "#0D2137"),
                    Color(hex: "#071020"),
                    Color(hex: "#0A0A0F")
                ],
                center: UnitPoint(x: 0.5, y: 0.65),
                startRadius: 20,
                endRadius: 160
            )
            .ignoresSafeArea()

            // Layer 2 — Earth sphere
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#1A3A2A"),
                            Color(hex: "#0D2137"),
                            Color(hex: "#162840")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 110, height: 110)
                .offset(y: 55)
                .overlay(
                    Circle()
                        .strokeBorder(
                            Color(hex: "#00E5FF").opacity(0.18),
                            lineWidth: 1
                        )
                        .frame(width: 114, height: 114)
                        .offset(y: 55)
                )

            // Layer 3 — City lights
            cityLightsOverlay

            // Layer 4 — User location dot
            ZStack {
                Circle()
                    .strokeBorder(Color(hex: "#34C759").opacity(0.35), lineWidth: 8)
                    .frame(width: 18, height: 18)
                Circle()
                    .fill(Color(hex: "#34C759"))
                    .frame(width: 7, height: 7)
            }
            .offset(y: 18)
        }
    }

    private var cityLightsOverlay: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { i in
                Circle()
                    .fill(Color(red: 1, green: 0.78, blue: 0.39, opacity: 0.5))
                    .frame(width: 2.5, height: 2.5)
                    .offset(
                        x: CGFloat([-12, 8, -5, 15][i]),
                        y: 55 + CGFloat([-8, 12, 20, 5][i])
                    )
            }
        }
    }

    // MARK: - Content layer

    private var contentLayer: some View {
        VStack(spacing: 0) {
            topBar
            Spacer()
            cardsStack
        }
    }

    private var topBar: some View {
        HStack {
            Text("ENDO")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color(hex: "#00E5FF"))
            Spacer()
            Text(Date(), style: .time)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(.horizontal, 10)
        .padding(.top, 6)
    }

    private var cardsStack: some View {
        VStack(spacing: 4) {
            zoneStatusCard
            mySignalsCard
            zoneMapCard
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 12)
    }

    // Card 1 — Zone Status (spec: large score, zone label, mini sparkline, progress bar)
    private var zoneStatusCard: some View {
        let zone = viewModel.currentZone
        let score = viewModel.compositeScore
        let history = viewModel.scoreHistory
        return cardShell(accent: zone.color) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(zone.color)
                Text(zone.rawValue)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(zone.color)
                miniSparkline(scores: history, fallback: score, color: zone.color)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(.white.opacity(0.15))
                            .frame(height: 2)
                        RoundedRectangle(cornerRadius: 1)
                            .fill(zone.color)
                            .frame(width: geo.size.width * CGFloat(score) / 100, height: 2)
                    }
                }
                .frame(height: 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // Card 2 — My Signals
    private var mySignalsCard: some View {
        let topSignals = ["Heart Rate", "AQI", "PM2.5"]
        return cardShell(accent: Color(hex: "#FFB800")) {
            VStack(alignment: .leading, spacing: 4) {
                Text("MY SIGNALS")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color(hex: "#FFB800"))
                Text("\(selectedSignalsCount) tracking")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                Text(topSignals.joined(separator: " · "))
                    .font(.system(size: 9, weight: .regular))
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // Card 3 — Zone Map
    private var zoneMapCard: some View {
        NavigationLink(value: MapDestination.map) {
            cardShell(accent: Color(hex: "#00E5FF")) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ZONE MAP")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color(hex: "#00E5FF"))
                    Text("Open Map")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }

    private func cardShell<Content: View>(accent: Color, @ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(10)
            .background(Color(red: 0/255, green: 10/255, blue: 20/255).opacity(0.6))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(accent.opacity(0.2), lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func miniSparkline(scores: [Int], fallback: Int, color: Color) -> some View {
        let points = scores.isEmpty ? [fallback] : scores
        return HStack(spacing: 2) {
            ForEach(0..<min(5, points.count), id: \.self) { i in
                let h = 2.0 + 8.0 * Double(points[i]) / 100.0
                RoundedRectangle(cornerRadius: 0.5)
                    .fill(color.opacity(0.6 + 0.4 * Double(points[i]) / 100))
                    .frame(width: 4, height: max(2, h))
            }
        }
        .frame(height: 10)
    }
}

// MARK: - Map destination (for NavigationLink)

private enum MapDestination: Hashable {
    case map
}

#Preview {
    HomeView()
}
