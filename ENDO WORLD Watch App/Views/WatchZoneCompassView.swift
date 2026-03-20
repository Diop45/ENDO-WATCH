import SwiftUI

// MARK: - WatchZoneCompassView
// Full-screen compass-style zone breakdown.
// Modeled on AllTrails compass rose — composite score at center,
// cardinal signals (AQI, HR, HRV, noise) at N/E/S/W positions.
// Tap anywhere to dismiss.

struct WatchZoneCompassView: View {

    @Environment(WatchZoneViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    @State private var arcProgress: Double = 0

    private var zoneColor: Color { viewModel.currentZone.color }

    var body: some View {
        ZStack {
            Color(hex: "#0A0A0F").ignoresSafeArea()

            compassDial
        }
        .onTapGesture { dismiss() }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                arcProgress = Double(viewModel.compositeScore) / 100.0
            }
        }
    }

    // MARK: - Compass dial

    private var compassDial: some View {
        ZStack {
            tickMarks
            scoreArc
            centerLabel
            cardinalLabels
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Tick marks

    private var tickMarks: some View {
        ForEach(0..<36, id: \.self) { i in
            Rectangle()
                .fill(.white.opacity(i % 9 == 0 ? 0.6 : 0.2))
                .frame(width: i % 9 == 0 ? 2 : 1, height: i % 9 == 0 ? 8 : 4)
                .offset(y: -72)
                .rotationEffect(.degrees(Double(i) * 10))
        }
    }

    // MARK: - Score arc

    private var scoreArc: some View {
        Circle()
            .trim(from: 0, to: arcProgress)
            .stroke(
                AngularGradient(
                    colors: [zoneColor.opacity(0.3), zoneColor],
                    center: .center
                ),
                style: StrokeStyle(lineWidth: 4, lineCap: .round)
            )
            .frame(width: 110, height: 110)
            .rotationEffect(.degrees(-90))
    }

    // MARK: - Center label

    private var centerLabel: some View {
        VStack(spacing: 2) {
            Text("\(viewModel.compositeScore)")
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(zoneColor)
            Text(viewModel.currentZone.rawValue)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    // MARK: - Cardinal signal labels

    private var cardinalLabels: some View {
        ZStack {
            // North — AQI
            cardinalItem(label: "AQI", value: "\(viewModel.aqi)")
                .offset(y: -54)

            // East — Heart Rate
            cardinalItem(label: "HR", value: "\(Int(viewModel.heartRate))")
                .offset(x: 54)

            // South — HRV
            cardinalItem(label: "HRV", value: "\(Int(viewModel.hrv))")
                .offset(y: 54)

            // West — Noise
            cardinalItem(label: "dB", value: "\(Int(viewModel.noiseLevel))")
                .offset(x: -54)
        }
    }

    private func cardinalItem(label: String, value: String) -> some View {
        VStack(spacing: 1) {
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
            Text(value)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}
