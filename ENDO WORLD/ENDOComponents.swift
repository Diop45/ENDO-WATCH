import SwiftUI

struct ENDOProgressBar: View {
    var value: Double
    var color: Color
    var height: CGFloat = 3

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(
                    cornerRadius: height / 2)
                    .fill(.white.opacity(0.07))
                    .frame(height: height)
                RoundedRectangle(
                    cornerRadius: height / 2)
                    .fill(color)
                    .frame(
                        width: geo.size.width
                            * max(0, min(1, value)),
                        height: height)
            }
        }
        .frame(height: height)
    }
}

struct ENDOMetricCell: View {
    let label: String
    let value: String
    let color: Color
    var bg: Color = .bgElevated

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white.opacity(0.30))
                .kerning(0.8)
                .textCase(.uppercase)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 9)
        .padding(.vertical, 8)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct ENDOSparkline: View {
    let values: [Double]
    let color: Color

    var body: some View {
        Canvas { ctx, size in
            guard values.count > 1 else { return }
            let mn = values.min() ?? 0
            let mx = values.max() ?? 1
            let range = mx - mn
            guard range > 0 else { return }
            let w = size.width
                / Double(values.count - 1)
            var path = Path()
            for (i, v) in values.enumerated() {
                let x = Double(i) * w
                let y = size.height
                    - ((v - mn) / range) * size.height
                let pt = CGPoint(x: x, y: y)
                if i == 0 { path.move(to: pt) }
                else { path.addLine(to: pt) }
            }
            ctx.stroke(
                path,
                with: .color(color.opacity(0.70)),
                style: StrokeStyle(
                    lineWidth: 1.5,
                    lineCap: .round,
                    lineJoin: .round))
            if let last = values.last {
                let x = size.width
                let y = size.height
                    - ((last - mn) / range) * size.height
                let dot = Path(ellipseIn: CGRect(
                    x: x - 3.5, y: y - 3.5,
                    width: 7, height: 7))
                ctx.fill(dot, with: .color(color))
            }
        }
    }
}

#Preview("Progress bar") {
    ENDOProgressBar(value: 0.62, color: .endoCyan)
        .frame(width: 220, height: 12)
        .padding()
        .background(Color.bgPrimary)
}

#Preview("Metric cell") {
    ENDOMetricCell(
        label: "AQI",
        value: "148",
        color: .endoRed)
        .padding()
        .background(Color.bgPrimary)
}

#Preview("Sparkline") {
    ENDOSparkline(
        values: MockService.aqiTrend(),
        color: .endoAmber)
        .frame(width: 280, height: 52)
        .padding()
        .background(Color.bgPrimary)
}
