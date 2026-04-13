import SwiftUI

struct ProximityRevealCard: View {
    let node: HealthNode
    var isMatchingStripCondition: Bool = false
    let onExpand: () -> Void
    let onDismiss: () -> Void

    private var isPositive: Bool {
        node.type.isPositive
    }

    private var accentColor: Color {
        isPositive
            ? node.type.defaultLens.color
            : node.primaryLens.color
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(accentColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: node.type.icon)
                    .font(.system(
                        size: 15, weight: .semibold))
                    .foregroundStyle(accentColor)
            }
            VStack(alignment: .leading,
                   spacing: 3) {
                Text(
                    node.envMetricValue
                    + " · "
                    + node.envMetricLabel)
                    .font(.system(
                        size: 9, weight: .medium))
                    .foregroundStyle(
                        node.envMetricColor.opacity(0.70))
                    .kerning(0.8)
                    .textCase(.uppercase)
                Text(node.insightWord)
                    .font(.system(
                        size: 16, weight: .bold))
                    .foregroundStyle(.white)
                Text(node.interpretation)
                    .font(.system(size: 11))
                    .foregroundStyle(
                        .white.opacity(0.50))
                    .lineLimit(1)
                if isMatchingStripCondition {
                    HStack(spacing: 5) {
                        Rectangle()
                            .fill(accentColor.opacity(0.50))
                            .frame(width: 2, height: 16)
                        Text(
                            "This is what your strip is tracking.")
                            .font(.system(size: 9))
                            .foregroundStyle(
                                .white.opacity(0.35))
                    }
                    .padding(.top, 4)
                }
            }
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(
                        size: 11, weight: .medium))
                    .foregroundStyle(
                        .white.opacity(0.35))
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.bgSheet.opacity(0.97))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 14,
                style: .continuous))
        .overlay(
            RoundedRectangle(
                cornerRadius: 14,
                style: .continuous)
                .strokeBorder(
                    accentColor.opacity(
                        isPositive ? 0.35 : 0.25),
                    lineWidth: 0.5))
        .contentShape(Rectangle())
        .onTapGesture { onExpand() }
    }
}

#Preview {
    ProximityRevealCard(
        node: MockService.nodes()[0],
        onExpand: {},
        onDismiss: {})
        .padding()
        .background(Color.bgPrimary)
}
