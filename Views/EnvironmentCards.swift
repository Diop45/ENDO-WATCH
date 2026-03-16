import SwiftUI

// MARK: - AQI half-arc gauge

private struct AQIGauge: View {
    let aqi: Int

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height)
            let radius = min(size.width / 2, size.height) - 4

            // Background arc
            let bgPath = Path { p in
                p.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .degrees(180),
                    endAngle: .degrees(0),
                    clockwise: false
                )
            }
            context.stroke(bgPath, with: .color(Color(hex: "#DDDDDD")), lineWidth: 5)

            // Foreground arc
            let proportion = min(1.0, Double(aqi) / 200.0)
            let endDegrees = 180.0 - proportion * 180.0
            let fgPath = Path { p in
                p.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .degrees(180),
                    endAngle: .degrees(endDegrees),
                    clockwise: false
                )
            }
            context.stroke(
                fgPath,
                with: .linearGradient(
                    Gradient(colors: [.iridescentA, .iridescentB]),
                    startPoint: CGPoint(x: 0, y: size.height),
                    endPoint: CGPoint(x: size.width, y: size.height)
                ),
                lineWidth: 5
            )
        }
        .frame(height: 28)
    }
}

// MARK: - AQICard

struct AQICard: View {

    let viewModel: ENDOWatchViewModel

    private var statusWord: String {
        switch viewModel.aqi {
        case ..<50:  return "Good"
        case 50...100: return "Moderate"
        default:     return "Unhealthy"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "wind")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.labelGray)
                Text("Air Quality")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.labelGray)
                Spacer()
                Text("EPA")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.labelGray)
            }

            AQIGauge(aqi: viewModel.aqi)
                .frame(height: 32)

            Text(statusWord)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.nearBlack)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(viewModel.aqi)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.nearBlack)
                Text("AQI")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.labelGray)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - PM25Card

struct PM25Card: View {

    let viewModel: ENDOWatchViewModel

    private var statusWord: String {
        switch viewModel.pm25 {
        case ..<12:  return "Clean"
        case 12...35: return "Moderate"
        default:     return "Heavy"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "aqi.medium")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.labelGray)
                Text("PM2.5")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.labelGray)
                Spacer()
                Text("EPA")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.labelGray)
            }

            Text(statusWord)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.nearBlack)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(String(format: "%.1f", viewModel.pm25))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.nearBlack)
                Text("µg/m³")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.labelGray)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - NoiseCard

struct NoiseCard: View {

    let viewModel: ENDOWatchViewModel

    private var statusWord: String {
        switch viewModel.noiseLevel {
        case ..<55: return "Quiet"
        case 55...70: return "Active"
        default:    return "Loud"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "ear")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.labelGray)
                Text("Noise")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.labelGray)
                Spacer()
                Text("HealthKit")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.labelGray)
            }

            Text(statusWord)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.nearBlack)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(Int(viewModel.noiseLevel))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.nearBlack)
                Text("dB")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.labelGray)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
