import SwiftUI

// MARK: - ConcentrationAnnotationView

struct ConcentrationAnnotationView: View {
    let cluster: ConditionCluster

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(
                    categoryColor(cluster.dominantCategory),
                    lineWidth: 1.5
                )
                .frame(width: 28, height: 28)

            Circle()
                .fill(
                    categoryColor(cluster.dominantCategory).opacity(0.15)
                )
                .frame(width: 28, height: 28)

            VStack(spacing: 0) {
                Text("\(cluster.concentrationScore)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(categoryColor(cluster.dominantCategory))
                Image(systemName: categoryIcon(cluster.dominantCategory))
                    .font(.system(size: 7, weight: .medium))
                    .foregroundStyle(categoryColor(cluster.dominantCategory).opacity(0.8))
            }

            Circle()
                .strokeBorder(
                    cluster.dominantZone.color.opacity(0.6),
                    lineWidth: 2.5
                )
                .frame(width: 34, height: 34)
        }
        .frame(width: 34, height: 34)
    }
}
