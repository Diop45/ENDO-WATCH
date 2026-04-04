import SwiftUI

struct VitalsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Vitals")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.bottom, 4)

                Text("Environment")
                    .capsLabel()

                VitalsEnvSection()

                Text("Biometrics")
                    .capsLabel()
                    .padding(.top, 8)

                VitalsBioSection()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
        .background(Color.bgPrimary.ignoresSafeArea())
    }
}

private struct VitalsEnvSection: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VitalsSparkCard(
                title: "Air Quality (AQI)",
                value: "\(appState.aqi)",
                color: aqiColor(appState.aqi),
                series: MockService.aqiTrend()
            )
            VitalsSparkCard(
                title: "PM2.5 (µg/m³)",
                value: String(format: "%.1f", appState.pm25),
                color: pm25Color(appState.pm25),
                series: MockService.aqiTrend().map { $0 * 0.3 }
            )
            HStack(spacing: 8) {
                ENDOMetricCell(label: "Noise", value: "\(appState.noiseDB) dB", color: noiseColor(appState.noiseDB))
                ENDOMetricCell(label: "Heat index", value: "\(appState.heatF)°F", color: .endoAmber)
            }
        }
    }
}

private struct VitalsBioSection: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VitalsSparkCard(
                title: "Heart rate variability",
                value: "\(Int(appState.hrv)) ms",
                color: hrvColor(appState.hrv),
                series: MockService.hrvValues()
            )
            VitalsSparkCard(
                title: "Resting heart rate",
                value: "\(Int(appState.hr)) bpm",
                color: hrColor(appState.hr),
                series: MockService.hrValues()
            )
            HStack(spacing: 8) {
                ENDOMetricCell(label: "SpO₂", value: "\(Int(appState.spo2))%", color: .endoGreen)
                ENDOMetricCell(label: "Resp. rate", value: "\(Int(appState.rr)) /min", color: .white.opacity(0.85))
            }
        }
    }
}

private struct VitalsSparkCard: View {
    let title: String
    let value: String
    let color: Color
    let series: [Double]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
                Spacer()
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(color)
            }
            ENDOSparkline(values: series, color: color)
                .frame(height: 44)
        }
        .padding(12)
        .endoCard(bg: .bgCard, border: .white.opacity(0.08))
    }
}
