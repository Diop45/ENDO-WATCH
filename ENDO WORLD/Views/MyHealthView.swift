import SwiftUI
import Charts

struct MyHealthView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedPeriod = "1M"
    @State private var selectedDate = Date()

    private let periods = ["1W", "1M", "3M", "1Y"]
    private let healthAreas: [(HealthArea, String, Color)] = [
        (.cardiovascular, "Cardiovascular Health", Color.ouraReadiness),
        (.environmental, "Environmental Exposure", Color.endoCyan),
        (.sleep, "Sleep Quality", Color.ouraSleep),
        (.stress, "Stress Load", Color.ouraStress),
        (.activity, "Activity Level", Color.ouraActivity),
        (.neighborhood, "Neighborhood Health", Color.endoCyan)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    healthAreasSection
                    trendChartsSection
                    conditionExposureSection
                    correlationInsightsSection
                    resilienceScoreSection
                    advisorSection
                }
                .padding(.bottom, 24)
            }
            .background(Color.endoBackground)
            .navigationTitle("My Health")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(periods, id: \.self) { p in
                            Button(p) { selectedPeriod = p }
                        }
                    } label: {
                        Text(selectedPeriod)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.endoCyan)
                    }
                }
            }
        }
    }

    private var healthAreasSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Health Areas")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
            ForEach(healthAreas, id: \.0) { area, label, color in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(label)
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.9))
                        Spacer()
                        Text("\(appState.healthAreaScores[area] ?? 0)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(color)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.white.opacity(0.1))
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(color)
                                .frame(width: geo.size.width * CGFloat(appState.healthAreaScores[area] ?? 0) / 100, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(12)
                .background(Color.endoSurface)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(16)
    }

    private var trendChartsSection: some View {
        let sampleData = (0..<30).map { i in
            (date: Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date(), score: 65 + Int.random(in: -15...15))
        }.reversed()
        return VStack(alignment: .leading, spacing: 16) {
            Text("Trends")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
            Chart(sampleData, id: \.date) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Score", point.score)
                )
                .foregroundStyle(Color.endoCyan)
                .interpolationMethod(.catmullRom)
            }
            .frame(height: 120)
            .chartYScale(domain: 0...100)
        }
        .padding(16)
        .background(Color.endoSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    private var conditionExposureSection: some View {
        let aqiData = (0..<14).map { i in
            (date: Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date(), value: 30 + Int.random(in: 0...80))
        }.reversed()
        return VStack(alignment: .leading, spacing: 16) {
            Text("What your neighborhood has exposed you to")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
            Chart(aqiData, id: \.date) { day in
                BarMark(
                    x: .value("Date", day.date),
                    y: .value("AQI", day.value)
                )
                .foregroundStyle(day.value <= 50 ? Color.endoGreen : (day.value <= 100 ? Color.endoAmber : Color.endoRed))
            }
            .frame(height: 100)
        }
        .padding(16)
        .background(Color.endoSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    private var correlationInsightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Biometric correlation insights")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
            insightRow(
                icon: "wind",
                text: "On days when AQI > 100, your HRV was 12% lower.",
                color: Color.endoCyan
            )
            insightRow(
                icon: "heart.fill",
                text: "Your resting HR is 4bpm higher in hostile zones.",
                color: Color.endoRed
            )
            insightRow(
                icon: "moon.fill",
                text: "Sleep quality dropped 18% during the week of high PM2.5 readings in early February.",
                color: Color.ouraSleep
            )
        }
        .padding(16)
        .background(Color.endoSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    private func insightRow(icon: String, text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
                .frame(width: 28, alignment: .center)
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.9))
            Spacer()
        }
        .padding(12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var resilienceScoreSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resilience Score")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
            Text("How well your body is adapting to your environment.")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.6))
            HStack {
                Text("78")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(Color.ouraReadiness)
                Spacer()
                Chart((0..<30).map { i in (i: i, v: 70 + Double(i % 5)) }, id: \.i) { p in
                    LineMark(x: .value("i", p.i), y: .value("v", p.v))
                        .foregroundStyle(Color.ouraReadiness.opacity(0.6))
                }
                .frame(width: 80, height: 40)
            }
            .padding(16)
            .background(Color.endoSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(16)
        .background(Color.endoSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    private var advisorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ENDO Advisor")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
            Text("Ask about your health, environment, or routes.")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.6))
            HStack(spacing: 8) {
                ForEach(["My worst exposure days", "Best zones nearby", "This week vs last"], id: \.self) { pill in
                    Text(pill)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.endoCyan)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.endoCyan.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            HStack {
                TextField("Ask ENDO...", text: .constant(""))
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color.endoSurfaceElev)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Button(action: {}) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.endoCyan)
                }
            }
        }
        .padding(16)
        .background(Color.endoSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }
}
