import SwiftUI

struct TodayView: View {
    @Environment(AppState.self) private var appState

    private var challenges: [ENDOChallenge] {
        MockService.challenges()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                TodayHeaderStrip()
                TodayZoneHeroCard()
                TodayChallengesSection(challenges: challenges)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
        .background(appState.atmosphericBackground.ignoresSafeArea())
    }
}

private struct TodayHeaderStrip: View {
    var body: some View {
        HStack {
            Text("Your zone · Detroit, MI")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.45))
            Spacer()
            Text(Date.now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.35))
        }
    }
}

private struct TodayZoneHeroCard: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Zone · public health")
                .capsLabel()

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(appState.zoneScore)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
                Text(appState.zone.rawValue.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(appState.zone.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(appState.zone.bgTint)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(appState.zone.borderTint, lineWidth: 0.5)
                    )
            }

            Text("Dominant signal · \(appState.dominantSignal)")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.55))

            Text("Environment")
                .capsLabel()
                .padding(.top, 4)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 8
            ) {
                ENDOMetricCell(label: "AQI", value: "\(appState.aqi)", color: aqiColor(appState.aqi))
                ENDOMetricCell(label: "PM2.5", value: String(format: "%.1f", appState.pm25), color: pm25Color(appState.pm25))
                ENDOMetricCell(label: "Noise", value: "\(appState.noiseDB) dB", color: noiseColor(appState.noiseDB))
                ENDOMetricCell(label: "Heat", value: "\(appState.heatF)°F", color: .endoAmber)
            }

            Text("Biometrics")
                .capsLabel()
                .padding(.top, 4)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 8
            ) {
                ENDOMetricCell(label: "HR", value: "\(Int(appState.hr)) bpm", color: hrColor(appState.hr))
                ENDOMetricCell(label: "HRV", value: "\(Int(appState.hrv)) ms", color: hrvColor(appState.hrv))
                ENDOMetricCell(label: "SpO₂", value: "\(Int(appState.spo2))%", color: .endoGreen)
                ENDOMetricCell(label: "RR", value: "\(Int(appState.rr)) /min", color: .white.opacity(0.85))
            }
        }
        .padding(14)
        .endoCard(bg: .bgCard, border: .white.opacity(0.08))
    }
}

private struct TodayChallengesSection: View {
    let challenges: [ENDOChallenge]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ENDOSectionHeader(title: "Active challenges", onAction: nil)
            ForEach(challenges) { ch in
                TodayChallengeRow(challenge: ch)
            }
        }
    }
}

private struct TodayChallengeRow: View {
    let challenge: ENDOChallenge

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(challenge.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text("+\(challenge.xp) XP")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(challenge.lensColor)
            }
            Text(challenge.isCollective ? "\(challenge.participants) participants" : "Solo")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.4))
            ENDOProgressBar(value: challenge.progress, color: challenge.lensColor)
        }
        .padding(12)
        .endoCard(bg: .bgSurface, border: .white.opacity(0.08))
        .contentShape(Rectangle())
    }
}
