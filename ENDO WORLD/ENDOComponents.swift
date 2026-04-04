import SwiftUI

struct ENDOProgressBar: View {
    var value: Double
    var color: Color
    var height: CGFloat = 3

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(.white.opacity(0.07))
                    .frame(height: height)
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color)
                    .frame(
                        width: geo.size.width * max(0, min(1, value)),
                        height: height
                    )
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
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 9)
        .padding(.vertical, 8)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct ENDOSectionHeader: View {
    let title: String
    var actionLabel: String = "See all"
    var onAction: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.32))
                .kerning(1.2)
                .textCase(.uppercase)
            Spacer()
            if let onAction {
                Button(actionLabel, action: onAction)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.endoCyan)
                    .contentShape(Rectangle())
            }
        }
    }
}

struct ENDOGlobe: View {
    var size: CGFloat = 80

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "#0D1E30"))
                .frame(width: size, height: size)
            Circle()
                .strokeBorder(Color.endoCyan.opacity(0.18), lineWidth: 1.5)
                .frame(width: size, height: size)
            ForEach([0.82, 0.62, 0.44, 0.28], id: \.self) { ratio in
                let opacity = 0.10 + (1 - ratio) * 0.20
                Circle()
                    .strokeBorder(Color.endoCyan.opacity(opacity), lineWidth: 0.8)
                    .frame(width: size * ratio, height: size * ratio)
            }
            Circle()
                .fill(Color.endoCyan.opacity(0.15))
                .frame(width: size * 0.18, height: size * 0.18)
            Circle()
                .fill(Color.endoCyan.opacity(0.90))
                .frame(width: size * 0.08, height: size * 0.08)
            Circle()
                .fill(Color.endoGreen)
                .frame(width: size * 0.10, height: size * 0.10)
                .overlay(
                    Circle()
                        .strokeBorder(Color.bgDark, lineWidth: 1.5)
                )
                .offset(x: size * 0.30, y: -(size * 0.30))
        }
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
            let w = size.width / Double(values.count - 1)
            var path = Path()
            for (i, v) in values.enumerated() {
                let x = Double(i) * w
                let y = size.height - ((v - mn) / range) * size.height
                let pt = CGPoint(x: x, y: y)
                if i == 0 { path.move(to: pt) }
                else { path.addLine(to: pt) }
            }
            ctx.stroke(
                path,
                with: .color(color.opacity(0.70)),
                style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round)
            )
            if let last = values.last {
                let x = size.width
                let y = size.height - ((last - mn) / range) * size.height
                let dot = Path(ellipseIn: CGRect(x: x - 3.5, y: y - 3.5, width: 7, height: 7))
                ctx.fill(dot, with: .color(color))
            }
        }
    }
}

struct ENDOTabBar: View {
    @Binding var selected: AppRouter.ENDOTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppRouter.ENDOTab.allCases, id: \.self) { tab in
                Button {
                    selected = tab
                } label: {
                    VStack(spacing: 2) {
                        Circle()
                            .fill(selected == tab ? Color.endoCyan : .clear)
                            .frame(width: 4, height: 4)
                        Image(systemName: tab.icon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(selected == tab ? Color.endoCyan : .white.opacity(0.32))
                        Text(tab.label)
                            .font(.system(size: 10, weight: selected == tab ? .semibold : .regular))
                            .foregroundStyle(selected == tab ? Color.endoCyan : .white.opacity(0.32))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .background(
            Color.bgCard
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(.white.opacity(0.07))
                        .frame(height: 0.5)
                }
        )
    }
}
