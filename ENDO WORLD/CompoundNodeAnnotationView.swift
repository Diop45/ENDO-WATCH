import SwiftUI

struct CompoundNodeAnnotationView: View {
    let compound: CompoundNode
    let onTap: () -> Void
    @State private var pulsing = false

    private var px: NodeProximityState {
        compound.proximityState
    }

    private var dotColor: Color {
        px == .idle || px == .visited
            ? Color.white.opacity(0.70)
            : compound.dominantColor
    }

    private var dotFill: Color {
        px == .idle || px == .visited
            ? Color(hex: "#1A1A2E").opacity(0.80)
            : compound.dominantColor.opacity(0.25)
    }

    private var nodeSize: CGFloat {
        switch px {
        case .selected: return 20
        case .autoReveal: return 16
        case .nearby: return 13
        case .idle, .visited: return 11
        }
    }

    private var showCompoundLabel: Bool {
        px != .idle && px != .visited
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .strokeBorder(
                        dotColor.opacity(0.18),
                        lineWidth: 0.5)
                    .frame(
                        width: nodeSize + 14,
                        height: nodeSize + 14)

                if px != .idle, px != .visited {
                    Circle()
                        .strokeBorder(
                            dotColor.opacity(
                                pulsing ? 0 : 0.50),
                            lineWidth: 1.0)
                        .frame(
                            width: nodeSize + 22,
                            height: nodeSize + 22)
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
                            width: nodeSize + 30,
                            height: nodeSize + 30)
                    Circle()
                        .strokeBorder(
                            dotColor.opacity(0.60),
                            lineWidth: 1.0)
                        .frame(
                            width: nodeSize + 16,
                            height: nodeSize + 16)
                }

                ZStack {
                    Circle()
                        .fill(dotFill)
                        .frame(
                            width: nodeSize,
                            height: nodeSize)
                    Circle()
                        .strokeBorder(
                            dotColor,
                            lineWidth:
                                px == .selected
                                ? 1.5 : 1.0)
                        .frame(
                            width: nodeSize,
                            height: nodeSize)
                    Text(
                        "\(compound.constituents.count)")
                        .font(.system(
                            size: nodeSize * 0.38,
                            weight: .bold))
                        .foregroundStyle(dotColor)
                }
                .scaleEffect(
                    px == .selected ? 1.15 : 1.0)
                .animation(
                    .spring(
                        duration: 0.4,
                        bounce: 0.15),
                    value: compound.proximityState)

                if showCompoundLabel {
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(dotColor.opacity(0.40))
                            .frame(
                                width: 24, height: 0.5)
                            .offset(
                                x: nodeSize / 2 + 2,
                                y: 0)
                        VStack(
                            alignment: .leading,
                            spacing: 2
                        ) {
                            Text(
                                "\(compound.constituents.count) conditions")
                                .font(.system(
                                    size: 9,
                                    weight: .medium))
                                .foregroundStyle(
                                    .white.opacity(0.85))
                                .lineLimit(1)
                            Text(
                                compound.leadNode
                                    .envMetricValue
                                    + " · "
                                    + compound.leadNode
                                    .envMetricLabel)
                                .font(.system(
                                    size: 8,
                                    weight: .semibold))
                                .foregroundStyle(
                                    compound.leadNode
                                        .envMetricColor)
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
                                    dotColor.opacity(0.18),
                                    lineWidth: 0.5))
                        .offset(
                            x: nodeSize / 2 + 28,
                            y: 0)
                    }
                }
            }
            .frame(
                width: nodeSize + 120,
                height: max(nodeSize + 36, 44),
                alignment: .leading)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .onAppear { pulsing = true }
    }
}

#Preview("Nearby") {
    let nodes = MockService.nodes()
    let compound = CompoundNode(
        id: "c1",
        coordinate: nodes[0].coordinate,
        constituents: Array(nodes.prefix(2)),
        proximityState: .nearby)
    CompoundNodeAnnotationView(compound: compound, onTap: {})
        .padding(48)
        .background(Color.bgPrimary)
}

#Preview("Selected") {
    let nodes = MockService.nodes()
    let compound = CompoundNode(
        id: "c2",
        coordinate: nodes[0].coordinate,
        constituents: Array(nodes.prefix(2)),
        proximityState: .selected)
    CompoundNodeAnnotationView(compound: compound, onTap: {})
        .padding(48)
        .background(Color.bgPrimary)
}
