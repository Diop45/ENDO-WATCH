import SwiftUI

/// Sheet for compound nodes.
/// Lists all constituents in severity order.
/// Environmental data always first in
/// each constituent's metric grid.
struct CompoundNodeSheet: View {
    let compound: CompoundNode

    var body: some View {
        ScrollView(
            .vertical,
            showsIndicators: false
        ) {
            VStack(alignment: .leading,
                   spacing: 20) {

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {
                    Text("COMPOUND CONDITION")
                        .font(.system(
                            size: 9, weight: .medium))
                        .foregroundStyle(
                            compound.dominantColor
                                .opacity(0.65))
                        .kerning(1.2)
                        .textCase(.uppercase)
                    Text(
                        "\(compound.constituents.count) conditions in this area")
                        .font(.system(
                            size: 22,
                            weight: .bold))
                        .foregroundStyle(.white)
                    Text(
                        "Multiple public health conditions overlap at this location. Conditions are listed below in order of severity.")
                        .font(.system(size: 13))
                        .foregroundStyle(
                            .white.opacity(0.50))
                        .lineSpacing(3)
                }

                Divider()
                    .background(.white.opacity(0.08))

                ForEach(sortedConstituents,
                        id: \.id) { node in
                    CompoundConstituentRow(node: node)
                }

                if hasFoodDiseasePair {
                    compoundCorrelation
                }

                Spacer().frame(height: 32)
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
        }
        .background {
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: 22,
                    bottomLeading: 0,
                    bottomTrailing: 0,
                    topTrailing: 22),
                style: .continuous)
                .fill(.ultraThinMaterial)
        }
        .clipShape(
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: 22,
                    bottomLeading: 0,
                    bottomTrailing: 0,
                    topTrailing: 22),
                style: .continuous))
    }

    private var sortedConstituents: [HealthNode] {
        compound.constituents.sorted {
            !$0.type.isPositive
                && $1.type.isPositive
        }
    }

    private var hasFoodDiseasePair: Bool {
        let hasFood = compound.constituents
            .contains {
                $0.type == .foodDesert
            }
        let hasDisease = compound.constituents
            .contains {
                $0.type == .diabetesCluster
                || $0.type == .asthmaRisk
                || $0.type == .hypertensionZone
            }
        return hasFood && hasDisease
    }

    private var compoundCorrelation: some View {
        Text("This block has both a food desert designation and elevated disease burden. These conditions are structurally related — limited food access compounds metabolic disease risk.")
            .font(.system(size: 13))
            .foregroundStyle(.white.opacity(0.50))
            .lineSpacing(3)
            .padding(12)
            .background(
                Color.endoPurple.opacity(0.08))
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 10))
            .overlay(
                RoundedRectangle(
                    cornerRadius: 10)
                    .strokeBorder(
                        Color.endoPurple.opacity(0.18),
                        lineWidth: 0.5))
    }
}

#Preview {
    let nodes = MockService.nodes()
    let compound = CompoundNode(
        id: "preview-compound",
        coordinate: nodes[0].coordinate,
        constituents: Array(nodes.prefix(3)),
        proximityState: .nearby)
    CompoundNodeSheet(compound: compound)
        .frame(maxHeight: 520)
        .background(Color.bgPrimary)
}
