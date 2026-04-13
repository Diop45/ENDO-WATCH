import SwiftUI

struct NodeAnnotationView: View {
    let node: HealthNode
    /// Community challenges stay visually idle until the user joins.
    var challengePinnedIdle: Bool = false
    let onTap: () -> Void
    @State private var pulsing = false
    @State private var spinRotation: Double = 0

    private var px: NodeProximityState {
        challengePinnedIdle ? .idle : node.proximityState
    }

    private var dotSize: CGFloat {
        switch px {
        case .selected: return 18
        case .autoReveal: return 14
        case .nearby: return 12
        case .idle, .visited: return 10
        }
    }

    private var dotColor: Color {
        switch px {
        case .idle, .visited:
            return Color.white.opacity(0.70)
        case .nearby, .autoReveal, .selected:
            return node.primaryLens.color
        }
    }

    private var dotFill: Color {
        switch px {
        case .idle, .visited:
            return Color(hex: "#1A1A2E")
                .opacity(0.80)
        case .nearby, .autoReveal:
            return node.primaryLens.color
                .opacity(0.18)
        case .selected:
            return node.primaryLens.color
                .opacity(0.30)
        }
    }

    private var showWarningBadge: Bool {
        !node.type.isPositive
            && (node.score ?? 100) < 40
            && (px == .nearby || px == .autoReveal || px == .selected)
    }

    private var showLocationLabel: Bool {
        px == .selected || px == .autoReveal || px == .nearby
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .strokeBorder(
                        dotColor.opacity(0.18),
                        lineWidth: 0.5)
                    .frame(
                        width: dotSize + 14,
                        height: dotSize + 14)

                if px != .idle, px != .visited {
                    Circle()
                        .strokeBorder(
                            dotColor.opacity(
                                pulsing ? 0 : 0.50),
                            lineWidth: 1.0)
                        .frame(
                            width: dotSize + 22,
                            height: dotSize + 22)
                        .scaleEffect(
                            pulsing ? 1.50 : 1.0)
                        .animation(
                            .easeOut(duration: 1.8)
                                .repeatForever(
                                    autoreverses: false),
                            value: pulsing)
                }

                if px == .selected {
                    Circle()
                        .strokeBorder(
                            dotColor.opacity(0.35),
                            lineWidth: 0.8)
                        .frame(
                            width: dotSize + 30,
                            height: dotSize + 30)
                    Circle()
                        .strokeBorder(
                            dotColor.opacity(0.60),
                            lineWidth: 1.0)
                        .frame(
                            width: dotSize + 16,
                            height: dotSize + 16)
                }

                ZStack {
                    Circle()
                        .fill(dotFill)
                        .frame(
                            width: dotSize,
                            height: dotSize)
                    Circle()
                        .strokeBorder(
                            dotColor,
                            lineWidth:
                                px == .selected
                                ? 1.5 : 1.0)
                        .frame(
                            width: dotSize,
                            height: dotSize)

                    if node.isLoadingLiveData {
                        Circle()
                            .trim(from: 0, to: 0.75)
                            .stroke(
                                dotColor.opacity(0.60),
                                style: StrokeStyle(
                                    lineWidth: 1.0,
                                    lineCap: .round))
                            .frame(
                                width: dotSize + 4,
                                height: dotSize + 4)
                            .rotationEffect(
                                .degrees(spinRotation))
                            .onAppear {
                                spinRotation = 0
                                withAnimation(
                                    .linear(duration: 1.0)
                                        .repeatForever(
                                            autoreverses: false)
                                ) {
                                    spinRotation = 360
                                }
                            }
                            .onDisappear {
                                spinRotation = 0
                            }
                    }

                    if challengePinnedIdle {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(3)
                            .background(
                                Circle()
                                    .fill(Color.bgSheet.opacity(0.92)))
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        .white.opacity(0.2),
                                        lineWidth: 0.5))
                            .offset(x: dotSize * 0.48, y: -dotSize * 0.48)
                    } else if showWarningBadge {
                        ZStack {
                            Circle()
                                .fill(Color.endoAmber)
                                .frame(
                                    width: 8, height: 8)
                            Text("!")
                                .font(.system(
                                    size: 5,
                                    weight: .black))
                                .foregroundStyle(
                                    Color(hex: "#412402"))
                        }
                        .offset(
                            x: dotSize * 0.48,
                            y: -dotSize * 0.48)
                    }
                }
                .scaleEffect(
                    px == .selected ? 1.15 : 1.0)
                .animation(
                    .spring(
                        duration: 0.4,
                        bounce: 0.15),
                    value: node.proximityState)

                if showLocationLabel {
                    locationLabel
                }
            }
            .frame(
                width: dotSize + 120,
                height: max(dotSize + 36, 44),
                alignment: .leading)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .onAppear { pulsing = true }
    }

    private var locationLabel: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(dotColor.opacity(0.40))
                .frame(width: 24, height: 0.5)
                .offset(x: dotSize / 2 + 2, y: 0)

            VStack(alignment: .leading,
                   spacing: 2) {
                Text(node.title)
                    .font(.system(
                        size: 9, weight: .medium))
                    .foregroundStyle(
                        .white.opacity(0.85))
                    .lineLimit(1)
                Text(
                    node.envMetricValue
                        + " · "
                        + node.envMetricLabel)
                    .font(.system(
                        size: 8, weight: .semibold))
                    .foregroundStyle(
                        node.envMetricColor)
                    .lineLimit(1)
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(
                Color(hex: "#0A0A0F")
                    .opacity(0.82))
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 5,
                    style: .continuous))
            .overlay(
                RoundedRectangle(
                    cornerRadius: 5,
                    style: .continuous)
                    .strokeBorder(
                        dotColor.opacity(0.20),
                        lineWidth: 0.5))
            .offset(x: dotSize / 2 + 28, y: 0)
        }
    }
}

private func previewAnnotationNode(
    _ state: NodeProximityState
) -> HealthNode {
    var n = MockService.nodes()[0]
    n.proximityState = state
    return n
}

#Preview("Idle") {
    NodeAnnotationView(
        node: previewAnnotationNode(.idle),
        onTap: {})
        .padding(48)
        .background(Color.bgPrimary)
}

#Preview("Nearby") {
    NodeAnnotationView(
        node: previewAnnotationNode(.nearby),
        onTap: {})
        .padding(48)
        .background(Color.bgPrimary)
}

#Preview("Selected") {
    NodeAnnotationView(
        node: previewAnnotationNode(.selected),
        onTap: {})
        .padding(48)
        .background(Color.bgPrimary)
}
