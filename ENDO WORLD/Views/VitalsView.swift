import SwiftUI
import Charts

struct VitalsView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedDate = Date()
    @State private var expandedCard: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    DateStripView(selectedDate: $selectedDate)
                    expandableScoreCards
                    rawSignalsSection
                    publicHealthSection
                }
                .padding(.bottom, 24)
            }
            .background(Color.endoBackground)
            .navigationTitle("Vitals")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var expandableScoreCards: some View {
        VStack(spacing: 12) {
            expandableCard(
                id: "zone",
                title: "Zone Score",
                score: appState.compositeScore,
                classification: appState.zoneClassification.rawValue,
                summary: "\(appState.dominantSignal) driving",
                color: appState.zoneClassification.color,
                contributors: [
                    ("Air Quality (AQI)", "\(appState.aqi)", Double(appState.aqi) / 200, aqiStatus(appState.aqi)),
                    ("PM2.5 Exposure", String(format: "%.1f", appState.pm25), appState.pm25 / 55, pm25Status(appState.pm25)),
                    ("Noise Exposure", "\(Int(appState.noiseLevel))dB", (appState.noiseLevel - 40) / 60, "Fair"),
                    ("Heart Rate Stress", "\(Int(appState.heartRate)) bpm", max(0, (appState.heartRate - 60) / 80), "Good"),
                    ("HRV Stress", "\(Int(appState.hrv)) ms", max(0, 1 - appState.hrv / 80), "Good"),
                    ("Heat Index", "\(Int(appState.heatIndex))°F", max(0, (appState.heatIndex - 75) / 50), "Optimal")
                ]
            )
            expandableCard(
                id: "biometric",
                title: "Biometric Load",
                score: appState.biometricLoadScore,
                classification: "Good",
                summary: "HRV above baseline",
                color: Color.ouraReadiness,
                contributors: [
                    ("Resting Heart Rate", "\(Int(appState.heartRate)) bpm", 0.15, "Good"),
                    ("HRV Balance", "\(Int(appState.hrv)) ms", 0.48, "Good"),
                    ("SpO2", "\(Int(appState.spo2))%", 0.02, "Optimal"),
                    ("Respiratory Rate", "14 /min", 0.1, "Good"),
                    ("Body Temperature", "98.4°F", 0.05, "Optimal")
                ]
            )
            expandableCard(
                id: "environmental",
                title: "Environmental Score",
                score: appState.environmentalScore,
                classification: "Moderate",
                summary: "PM2.5 elevated",
                color: Color.endoCyan,
                contributors: [
                    ("AQI (EPA AirNow)", "\(appState.aqi)", Double(appState.aqi) / 200, aqiStatus(appState.aqi)),
                    ("PM2.5 (μg/m³)", String(format: "%.1f", appState.pm25), appState.pm25 / 55, pm25Status(appState.pm25)),
                    ("Noise Level (dB)", "\(Int(appState.noiseLevel))", (appState.noiseLevel - 40) / 60, "Fair"),
                    ("Heat Index (°F)", "\(Int(appState.heatIndex))", max(0, (appState.heatIndex - 75) / 50), "Good"),
                    ("Resource Density", "72%", 0.28, "Good")
                ]
            )
            expandableCard(
                id: "sleep",
                title: "Sleep",
                score: appState.sleepScore,
                classification: "Good",
                summary: "7h 32m total",
                color: Color.ouraSleep,
                contributors: [
                    ("Total Sleep", "7h 32m", 0.94, "Good"),
                    ("Efficiency", "92%", 0.92, "Optimal"),
                    ("REM", "1h 45m", 0.85, "Good"),
                    ("Deep", "1h 12m", 0.78, "Fair"),
                    ("Latency", "8m", 0.9, "Good"),
                    ("Timing", "11:02pm", 0.88, "Good")
                ]
            )
            expandableCard(
                id: "activity",
                title: "Activity",
                score: appState.activityScore,
                classification: "Fair",
                summary: "620 / 800 cal",
                color: Color.ouraActivity,
                contributors: []
            )
            expandableCard(
                id: "stress",
                title: "Stress",
                score: appState.stressScore,
                classification: "Moderate",
                summary: "12m stressed today",
                color: Color.ouraStress,
                contributors: []
            )
        }
        .padding(.horizontal, 16)
    }

    private func expandableCard(
        id: String,
        title: String,
        score: Int,
        classification: String,
        summary: String,
        color: Color,
        contributors: [(String, String, Double, String)]
    ) -> some View {
        let isExpanded = expandedCard == id
        return VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    expandedCard = isExpanded ? nil : id
                }
            }) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .strokeBorder(.white.opacity(0.08), lineWidth: 4)
                        Circle()
                            .trim(from: 0, to: CGFloat(score) / 100)
                            .stroke(color, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        Text("\(score)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 48, height: 48)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(score) · \(classification)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                        Text(summary)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(16)
            }
            .buttonStyle(.plain)
            if isExpanded && !contributors.isEmpty {
                VStack(spacing: 0) {
                    Divider().background(.white.opacity(0.1)).padding(.horizontal, 16)
                    ForEach(contributors.indices, id: \.self) { i in
                        ContributorBarRow(
                            label: contributors[i].0,
                            value: contributors[i].1,
                            progress: min(1, max(0, contributors[i].2)),
                            color: color,
                            status: contributors[i].3
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                    }
                }
                .padding(.bottom, 16)
            }
        }
        .background(Color.endoSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var rawSignalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Raw Signals")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
            Text("Biometric · Environmental · Movement · Urban · Patterns")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.5))
            VStack(spacing: 8) {
                rawSignalRow("Heart Rate", "\(Int(appState.heartRate)) bpm", Color.ouraHR)
                rawSignalRow("HRV", "\(Int(appState.hrv)) ms", Color.endoCyan)
                rawSignalRow("AQI", "\(appState.aqi)", aqiColor(appState.aqi))
                rawSignalRow("PM2.5", String(format: "%.1f", appState.pm25), pm25Color(appState.pm25))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.endoSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    private func rawSignalRow(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.9))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
            Text("Above baseline")
                .font(.system(size: 10))
                .foregroundStyle(color.opacity(0.8))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(color.opacity(0.2))
                .clipShape(Capsule())
        }
        .padding(.vertical, 6)
    }

    private var publicHealthSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Public Health Indicators")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
            Text("CDC PLACES · SAMHSA · HRSA")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.5))
            VStack(spacing: 8) {
                publicHealthRow("Chronic disease prevalence", "12%", Color.endoCyan)
                publicHealthRow("Healthcare access score", "78", Color.endoGreen)
                publicHealthRow("Environmental burden index", "0.42", Color.endoAmber)
                publicHealthRow("Mental health resource density", "High", Color.ouraSleep)
                publicHealthRow("HRSA provider availability", "Good", Color.endoGreen)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.endoSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    private func publicHealthRow(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.9))
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(color)
        }
        .padding(.vertical, 6)
    }

    private func aqiStatus(_ aqi: Int) -> String {
        if aqi <= 50 { return "Optimal" }
        if aqi <= 100 { return "Good" }
        if aqi <= 150 { return "Fair" }
        return "Poor"
    }

    private func pm25Status(_ pm25: Double) -> String {
        if pm25 <= 12 { return "Optimal" }
        if pm25 <= 35.4 { return "Good" }
        if pm25 <= 55 { return "Fair" }
        return "Poor"
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
}
