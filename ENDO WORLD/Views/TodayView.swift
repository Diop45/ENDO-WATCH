import SwiftUI
import Charts

struct TodayView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedDate = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    DateStripView(selectedDate: $selectedDate)
                    scoreShortcutsRow
                    dailyHighlightCard
                    zoneStatusCard
                    biometricStreamCard
                    environmentalConditionsCard
                    daytimeStressCard
                    activityGoalCard
                    conditionExposureCard
                }
                .padding(.bottom, 24)
            }
            .background(Color.endoBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("ENDO")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.endoCyan)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Image(systemName: "battery.75")
                            .font(.system(size: 16))
                            .foregroundStyle(.white.opacity(0.6))
                        Circle()
                            .fill(Color.endoCyan.opacity(0.5))
                            .frame(width: 32, height: 32)
                    }
                }
            }
        }
    }

    private var scoreShortcutsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ScoreRingView(score: appState.compositeScore, label: "Zone", color: appState.zoneClassification.color)
                ScoreRingView(score: appState.biometricLoadScore, label: "Body", color: Color.ouraReadiness)
                ScoreRingView(score: appState.environmentalScore, label: "Environment", color: Color.endoCyan)
                ScoreRingView(score: appState.sleepScore, label: "Sleep", color: Color.ouraSleep)
                ScoreRingView(score: appState.activityScore, label: "Activity", color: Color.ouraActivity)
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
    }

    private var dailyHighlightCard: some View {
        cardContainer(accent: appState.zoneClassification.color) {
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(appState.zoneClassification.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "wind")
                            .font(.system(size: 18))
                            .foregroundStyle(appState.zoneClassification.color)
                    )
                VStack(alignment: .leading, spacing: 4) {
                    Text("PM2.5 is elevated on your usual route")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("Take Woodward Ave instead — AQI 28 there.")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
            }
            .padding(16)
        }
        .padding(.horizontal, 16)
    }

    private var zoneStatusCard: some View {
        cardContainer(accent: appState.zoneClassification.color) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Your zone · Detroit, MI")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                    Text(Date(), style: .time)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.4))
                }
                Text(appState.zoneClassification.rawValue)
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(appState.zoneClassification.color)
                Text("\(appState.compositeScore)/100")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.6))
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.white.opacity(0.1))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(appState.zoneClassification.color)
                            .frame(width: geo.size.width * CGFloat(appState.compositeScore) / 100, height: 6)
                    }
                }
                .frame(height: 6)
                Text(appState.dominantSignal)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.6))
                HStack(spacing: 8) {
                    SignalBadge(value: "\(appState.aqi)", label: "AQI", color: aqiColor(appState.aqi))
                    SignalBadge(value: String(format: "%.1f", appState.pm25), label: "PM2.5", color: pm25Color(appState.pm25))
                    SignalBadge(value: "\(Int(appState.heartRate))", label: "HR", color: Color.ouraHR)
                    SignalBadge(value: "\(Int(appState.hrv))", label: "HRV", color: Color.endoCyan)
                }
            }
            .padding(16)
        }
        .padding(.horizontal, 16)
    }

    private var biometricStreamCard: some View {
        cardContainer(accent: Color.ouraReadiness) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Biometrics · live")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(Int(appState.heartRate))")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                        Text("bpm")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.5))
                        SparklineView(data: [72, 68, 75, 70, 72, 74, 72])
                            .frame(height: 24)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(Int(appState.hrv))")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                        Text("ms")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.5))
                        Text("Above baseline")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.endoGreen)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.endoGreen.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(Int(appState.spo2))")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                        Text("%")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.5))
                        Image(systemName: "arrow.up")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.endoGreen)
                    }
                }
            }
            .padding(16)
        }
        .padding(.horizontal, 16)
    }

    private var environmentalConditionsCard: some View {
        cardContainer(accent: Color.endoCyan) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Your block · live")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                RoundedRectangle(cornerRadius: 12)
                    .fill(appState.zoneClassification.color.opacity(0.2))
                    .frame(height: 140)
                    .overlay(
                        Image(systemName: "map.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(appState.zoneClassification.color.opacity(0.5))
                    )
                HStack(spacing: 8) {
                    SignalBadge(value: "\(appState.aqi)", label: "AQI", color: aqiColor(appState.aqi))
                    SignalBadge(value: String(format: "%.1f", appState.pm25), label: "PM2.5", color: pm25Color(appState.pm25))
                    SignalBadge(value: "\(Int(appState.noiseLevel))dB", label: "Noise", color: noiseColor(appState.noiseLevel))
                    SignalBadge(value: "\(Int(appState.heatIndex))°", label: "Heat", color: Color.ouraStress)
                }
            }
            .padding(16)
        }
        .padding(.horizontal, 16)
    }

    private var daytimeStressCard: some View {
        cardContainer(accent: Color.ouraStress) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Stress today")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                HStack(spacing: 2) {
                    ForEach(0..<24, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(stressColor(for: i))
                            .frame(height: 24)
                    }
                }
                HStack(spacing: 16) {
                    Text("12m stressed")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.endoRed)
                    Text("2h 34m relaxed")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.endoCyan)
                    Text("45m restored")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.endoGreen)
                }
                Text("Noise exposure elevated your stress score between 10am–12pm")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(16)
        }
        .padding(.horizontal, 16)
    }

    private var activityGoalCard: some View {
        let goalPct = appState.zoneClassification == .supportive ? 1.0 :
                      appState.zoneClassification == .moderate ? 0.85 : 0.70
        return cardContainer(accent: Color.ouraActivity) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Activity goal")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                HStack {
                    ZStack {
                        Circle()
                            .trim(from: 0, to: 0.5 * goalPct * CGFloat(appState.activityScore) / 100)
                            .stroke(Color.ouraActivity, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .rotationEffect(.degrees(180))
                        Text("\(Int(620 * goalPct))/\(Int(800 * goalPct))")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 80, height: 80)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("620 cal")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                        Text("4,200 steps")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.6))
                        Text("32 min active")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    Spacer()
                }
            }
            .padding(16)
        }
        .padding(.horizontal, 16)
    }

    private var conditionExposureCard: some View {
        let events: [(Date, String, ZoneClassification, String)] = [
            (Calendar.current.date(bySettingHour: 8, minute: 2, second: 0, of: Date()) ?? Date(), "PM2.5 spike on Gratiot Ave", .hostile, "2.4mi"),
            (Calendar.current.date(bySettingHour: 10, minute: 15, second: 0, of: Date()) ?? Date(), "Noise 72dB+ near construction", .moderate, ""),
            (Calendar.current.date(bySettingHour: 14, minute: 30, second: 0, of: Date()) ?? Date(), "AQI improved entering Palmer Park", .supportive, "")
        ]
        return cardContainer(accent: Color.endoCyan) {
            VStack(alignment: .leading, spacing: 12) {
                Text("What you've been exposed to today")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                ForEach(events.indices, id: \.self) { i in
                    let (time, cond, zone, dist) = events[i]
                    HStack {
                        Text(time, style: .time)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(width: 50, alignment: .leading)
                        Text(cond)
                            .font(.system(size: 13))
                            .foregroundStyle(.white)
                        Spacer()
                        ZonePillView(zone: zone)
                        if !dist.isEmpty {
                            Text(dist)
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .padding(16)
        }
        .padding(.horizontal, 16)
    }

    private func cardContainer<Content: View>(accent: Color, @ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.endoSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(accent.opacity(0.3), lineWidth: 0.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(accent, lineWidth: 3)
                    .padding(1)
                    .mask(
                        HStack {
                            Rectangle().frame(width: 3)
                            Spacer()
                        }
                    )
            )
    }

    private func stressColor(for hour: Int) -> Color {
        if hour < 4 { return Color.endoCyan }
        if hour < 8 { return Color.endoGreen }
        if hour < 12 { return Color.endoRed }
        if hour < 16 { return Color.endoAmber }
        if hour < 20 { return Color.endoCyan }
        return Color.endoGreen
    }

    private func aqiColor(_ aqi: Int) -> Color {
        if aqi <= 50 { return Color.endoGreen }
        if aqi <= 100 { return Color.endoAmber }
        return Color.endoRed
    }

    private func pm25Color(_ pm25: Double) -> Color {
        if pm25 <= 12 { return Color.endoGreen }
        if pm25 <= 35.4 { return Color.endoAmber }
        return Color.endoRed
    }

    private func noiseColor(_ db: Double) -> Color {
        if db <= 55 { return Color.endoGreen }
        if db <= 70 { return Color.endoAmber }
        return Color.endoRed
    }
}

struct SparklineView: View {
    let data: [Double]

    var body: some View {
        Chart(Array(data.enumerated()), id: \.offset) { i, v in
            LineMark(
                x: .value("i", i),
                y: .value("v", v)
            )
            .foregroundStyle(Color.endoCyan)
            .interpolationMethod(.catmullRom)
        }
        .chartYScale(domain: (data.min() ?? 0) - 5...(data.max() ?? 100) + 5)
    }
}
