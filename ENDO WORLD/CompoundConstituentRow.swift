import SwiftUI

struct CompoundConstituentRow: View {
    let node: HealthNode

    var body: some View {
        VStack(alignment: .leading,
               spacing: 8) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            node.primaryLens.color
                                .opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: node.type.icon)
                        .font(.system(
                            size: 15,
                            weight: .semibold))
                        .foregroundStyle(
                            node.primaryLens.color)
                }
                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {
                    Text(node.title)
                        .font(.system(
                            size: 13,
                            weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(
                        node.envMetricValue
                        + " · "
                        + node.envMetricLabel)
                        .font(.system(
                            size: 12,
                            weight: .medium))
                        .foregroundStyle(
                            node.envMetricColor)
                }
                Spacer()
                Text(node.insightWord)
                    .font(.system(
                        size: 11,
                        weight: .semibold))
                    .foregroundStyle(
                        node.envMetricColor)
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())],
                spacing: 3
            ) {
                ForEach(
                    node.envMetrics.prefix(2)
                ) { m in
                    CompoundMiniMetricCell(
                        label: m.label,
                        value: m.value,
                        color: m.color)
                }
                if !node.bioMetrics.isEmpty {
                    ForEach(
                        node.bioMetrics.prefix(2)
                    ) { m in
                        CompoundMiniMetricCell(
                            label: m.label,
                            value: m.value,
                            color: m.color)
                    }
                }
            }

            if let action = node.actions.first {
                Button(action: {}) {
                    Text(action.label)
                }
                .font(.system(
                    size: 11, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    node.type.isPositive
                        ? Color.endoGreen
                        : Color.endoCyan)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 8))
                .buttonStyle(.plain)
                .contentShape(
                    RoundedRectangle(
                        cornerRadius: 8))
            }
        }
        .padding(12)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(
            cornerRadius: 12,
            style: .continuous))
        .overlay(
            RoundedRectangle(
                cornerRadius: 12,
                style: .continuous)
                .strokeBorder(
                    node.primaryLens.color
                        .opacity(0.20),
                    lineWidth: 0.5))
    }
}

#Preview {
    ScrollView {
        CompoundConstituentRow(node: MockService.nodes()[0])
            .padding()
    }
    .background(Color.bgPrimary)
}
