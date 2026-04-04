import SwiftUI

struct NodeDetailSheet: View {
    let node: HealthNode
    var onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(node.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Button("Done", action: onDismiss)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.endoCyan)
                    .contentShape(Rectangle())
            }
            .padding(.bottom, 8)

            Text(node.subtitle)
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.45))
                .padding(.bottom, 12)

            Text("Environment")
                .capsLabel()
                .padding(.bottom, 8)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(node.envMetrics) { m in
                    ENDOMetricCell(label: m.label, value: m.value, color: m.color)
                }
            }
            .padding(.bottom, 16)

            Text("Biometrics")
                .capsLabel()
                .padding(.bottom, 8)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(node.bioMetrics) { m in
                    ENDOMetricCell(label: m.label, value: m.value, color: m.color)
                }
            }
            .padding(.bottom, 16)

            Text(node.insightWord)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .padding(.bottom, 4)

            Text(node.interpretation)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.7))
                .padding(.bottom, 12)

            Text(node.whyItMatters)
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.55))
                .lineSpacing(3)
                .padding(.bottom, 12)

            Text("Correlation")
                .capsLabel()
                .padding(.bottom, 6)

            Text(node.correlationNote)
                .font(.system(size: 13))
                .foregroundStyle(Color.endoCyan.opacity(0.9))
                .padding(.bottom, 16)

            Text("Source · \(node.source)")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.35))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.bgSheet)
    }
}
