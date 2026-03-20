import SwiftUI

// MARK: - Sparkline shape

private struct SparklineLine: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        guard points.count > 1 else { return Path() }
        return Path { p in
            p.move(to: points[0])
            for pt in points.dropFirst() {
                p.addLine(to: pt)
            }
        }
    }
}

private struct SparklineFill: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        guard let first = points.first, let last = points.last else { return Path() }
        return Path { p in
            p.move(to: CGPoint(x: first.x, y: rect.height))
            p.addLine(to: first)
            for pt in points.dropFirst() {
                p.addLine(to: pt)
            }
            p.addLine(to: CGPoint(x: last.x, y: rect.height))
            p.closeSubpath()
        }
    }
}

private func normalizedPoints(values: [Double], size: CGSize) -> [CGPoint] {
    guard values.count > 1 else { return [] }
    let minVal = values.min() ?? 0
    let maxVal = values.max() ?? 1
    let range = maxVal - minVal
    return values.enumerated().map { i, v in
        let x = size.width * CGFloat(i) / CGFloat(values.count - 1)
        let y: CGFloat = range > 0
            ? size.height * CGFloat(1.0 - (v - minVal) / range)
            : size.height / 2
        return CGPoint(x: x, y: y)
    }
}

// MARK: - SparklineView

private struct SparklineView: View {
    let values: [Double]

    @State private var animationProgress: Double = 0

    var body: some View {
        GeometryReader { geo in
            let pts = normalizedPoints(values: values, size: geo.size)
            ZStack {
                SparklineFill(points: pts)
                    .fill(
                        LinearGradient(
                            colors: [Color.iridescentA.opacity(0.4), Color.iridescentB.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                SparklineLine(points: pts)
                    .trim(from: 0, to: animationProgress)
                    .stroke(Color(hex: "#AAAAAA"), lineWidth: 1.5)
            }
        }
        .onAppear {
            animationProgress = 0
            withAnimation(.easeInOut(duration: 0.8)) {
                animationProgress = 1.0
            }
        }
    }
}

// MARK: - HeartRateCard

struct HeartRateCard: View {

    let viewModel: ENDOWatchViewModel

    private var statusWord: String {
        switch viewModel.heartRate {
        case ..<90:  return "Normal"
        case 90...110: return "Elevated"
        default:     return "High"
        }
    }

    private var restingDelta: String {
        let delta = Int(viewModel.heartRate) - 70
        return delta >= 0 ? "+\(delta)" : "\(delta)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.labelGray)
                Text("Heart Rate")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.labelGray)
                Spacer()
                Text(restingDelta)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.labelGray)
            }

            SparklineView(values: viewModel.heartRateHistory)
                .frame(height: 32)

            Text(statusWord)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.nearBlack)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(Int(viewModel.heartRate))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.nearBlack)
                Text("bpm")
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

// MARK: - HRVCard

struct HRVCard: View {

    let viewModel: ENDOWatchViewModel

    private var statusWord: String {
        switch viewModel.hrv {
        case ..<20:   return "Stressed"
        case 20...40: return "Low"
        default:      return "Balanced"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.labelGray)
                Text("HRV")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.labelGray)
                Spacer()
                Text("Last 4w avg")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.labelGray)
            }

            SparklineView(values: viewModel.hrvHistory)
                .frame(height: 32)

            Text(statusWord)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.nearBlack)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(Int(viewModel.hrv))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.nearBlack)
                Text("ms")
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

// MARK: - VO2Card

struct VO2Card: View {

    let viewModel: ENDOWatchViewModel

    private var statusWord: String {
        switch viewModel.vo2Max {
        case ..<40: return "Fair"
        case 40...48: return "Good"
        default: return "Excellent"
        }
    }

    private var activeSegment: Int {
        switch viewModel.vo2Max {
        case ..<35:   return 0
        case 35..<42: return 1
        case 42..<48: return 2
        case 48..<55: return 3
        default:      return 4
        }
    }

    private let segmentLabels = ["Poor", "Fair", "Good", "Excellent", "Superior"]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "lungs.fill")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.labelGray)
                Text("VO² Max")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.labelGray)
                Spacer()
                Text("Apple Health")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.labelGray)
            }

            vo2RangeBar
                .frame(height: 32)

            Text(statusWord)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.nearBlack)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(String(format: "%.0f", viewModel.vo2Max))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.nearBlack)
                Text("mL/kg/min")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.labelGray)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var vo2RangeBar: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                ZStack(alignment: .trailing) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            index == activeSegment
                                ? AnyShapeStyle(LinearGradient.iridescent)
                                : AnyShapeStyle(Color(hex: "#DDDDDD"))
                        )
                        .frame(height: 6)

                    if index == activeSegment {
                        Rectangle()
                            .fill(Color.chartreuse)
                            .frame(width: 1.5, height: 14)
                    }
                }
            }
        }
    }
}
