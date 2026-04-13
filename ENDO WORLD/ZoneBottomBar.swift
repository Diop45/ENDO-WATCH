import Combine
import SwiftUI

/// Bottom map strip: cycles live public-health signals (air, particles, heat, noise, composite).
struct ZoneBottomBar: View {
    @Environment(AppState.self) private var appState
    var onNavigateOut: (() -> Void)? = nil

    @State private var tickerIndex = 0

    private let tickInterval: TimeInterval = 5

    private var tickerPages: [TickerPage] {
        var pages: [TickerPage] = []

        pages.append(
            TickerPage(
                label: "Air quality",
                value: "AQI \(appState.aqi)",
                caption: aqiCaption(appState.aqi),
                accent: aqiColor(appState.aqi)))

        pages.append(
            TickerPage(
                label: "Fine particles",
                value: String(
                    format: "PM2.5 %.1f µg/m³",
                    appState.pm25),
                caption: pm25Caption(appState.pm25),
                accent: pm25Color(appState.pm25)))

        pages.append(
            TickerPage(
                label: "Heat",
                value: "\(appState.heatF)°F",
                caption: heatCaption(appState.heatF),
                accent: heatColor(appState.heatF)))

        pages.append(
            TickerPage(
                label: "Noise",
                value: "\(appState.noiseDB) dB",
                caption: noiseCaption(appState.noiseDB),
                accent: noiseColor(appState.noiseDB)))

        pages.append(
            TickerPage(
                label: "Area index",
                value: "Score \(appState.zoneScore)",
                caption:
                    "\(appState.zone.rawValue) zone · composite signal",
                accent: zoneColor(appState.zoneScore)))

        if let alert = publicHealthAlert() {
            pages.append(alert)
        }

        return pages
    }

    var body: some View {
        let pages = tickerPages
        let safeIndex = pages.isEmpty
            ? 0
            : tickerIndex % pages.count
        let page = pages.isEmpty
            ? TickerPage(
                label: "Public health",
                value: "—",
                caption: "No live signals",
                accent: .white.opacity(0.5))
            : pages[safeIndex]

        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(page.label.uppercased())
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.38))
                    .kerning(0.8)
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(page.value)
                        .font(.system(
                            size: 15,
                            weight: .bold,
                            design: .rounded))
                        .foregroundStyle(page.accent)
                    Text(page.caption)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentTransition(.numericText())
            .animation(
                .easeInOut(duration: 0.35),
                value: tickerIndex)

            if appState.zone == .hostile {
                Button("Navigate out") {
                    onNavigateOut?()
                }
                .font(.system(
                    size: 12, weight: .semibold))
                .foregroundStyle(Color.cyanCTA)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.endoCyan)
                .clipShape(Capsule())
                .contentShape(Capsule())
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.bgElevated)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 12,
                style: .continuous))
        .overlay(
            RoundedRectangle(
                cornerRadius: 12,
                style: .continuous)
                .strokeBorder(
                    Color.white.opacity(0.10),
                    lineWidth: 0.5))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(page.label). \(page.value). \(page.caption)")
        .onReceive(
            Timer.publish(
                every: tickInterval,
                on: .main,
                in: .common
            ).autoconnect()
        ) { _ in
            let c = max(tickerPages.count, 1)
            tickerIndex = (tickerIndex + 1) % c
        }
    }

    private func aqiCaption(_ aqi: Int) -> String {
        switch aqi {
        case 0 ..< 51: return "Good air day for most"
        case 51 ..< 101: return "Moderate · sensitive groups watch"
        case 101 ..< 151: return "Unhealthy for sensitive groups"
        default: return "Unhealthy · limit outdoor exertion"
        }
    }

    private func pm25Caption(_ v: Double) -> String {
        if v < 12 { return "Below WHO annual guidance" }
        if v < 35.4 { return "Near interim WHO targets" }
        return "Elevated inhalation risk"
    }

    private func heatCaption(_ f: Int) -> String {
        if f < 80 { return "Typical heat load" }
        if f < 95 { return "Heat stress advisory band" }
        return "High heat · hydration & shade"
    }

    private func noiseCaption(_ db: Int) -> String {
        if db < 70 { return "Background urban sound" }
        if db < 85 { return "Elevated · prolonged exposure" }
        return "Loud · hearing protection zone"
    }

    private func publicHealthAlert() -> TickerPage? {
        if appState.aqi >= 101 {
            return TickerPage(
                label: "Public advisory",
                value: "Air quality alert",
                caption:
                    "AQI \(appState.aqi) · reduce outdoor activity",
                accent: aqiColor(appState.aqi))
        }
        if appState.pm25 >= 35.4 {
            return TickerPage(
                label: "Public advisory",
                value: "Particle load",
                caption:
                    "PM2.5 elevated · masks near traffic",
                accent: pm25Color(appState.pm25))
        }
        if appState.zone == .hostile {
            return TickerPage(
                label: "Public advisory",
                value: "Hostile zone",
                caption:
                    "Area stress index low · seek supportive blocks",
                accent: .endoRed)
        }
        return nil
    }
}

private struct TickerPage {
    let label: String
    let value: String
    let caption: String
    let accent: Color
}

private func heatColor(_ f: Int) -> Color {
    if f >= 95 { return .endoRed }
    if f >= 85 { return .endoAmber }
    return .endoGreen
}

#Preview("Ticker") {
    ZoneBottomBar()
        .environment(AppState())
        .padding()
        .background(Color.bgPrimary)
}

#Preview("Hostile + navigate") {
    HostileZoneBottomPreview()
        .padding()
        .background(Color.bgPrimary)
}

private struct HostileZoneBottomPreview: View {
    @State private var app = AppState()

    var body: some View {
        ZoneBottomBar(onNavigateOut: {})
            .environment(app)
            .onAppear {
                app.zone = .hostile
                app.zoneScore = 22
                app.aqi = 156
            }
    }
}
