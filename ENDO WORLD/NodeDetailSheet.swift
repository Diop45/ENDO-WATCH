import SwiftUI

private func nodeRefreshedCaption(
    _ date: Date?
) -> String {
    guard let date else { return "" }
    let f = RelativeDateTimeFormatter()
    f.unitsStyle = .abbreviated
    return f.localizedString(
        for: date,
        relativeTo: Date())
}

struct NodeDetailSheet: View {
    let node: HealthNode?
    var onExitChallenge: (() -> Void)? = nil

    var body: some View {
        Group {
            if let node {
                ScrollView(.vertical,
                           showsIndicators: false) {
                    VStack(alignment: .leading,
                           spacing: 20) {
                        if node.type == .communityChallenge,
                           let exit = onExitChallenge
                        {
                            Button(action: exit) {
                                HStack(spacing: 8) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(
                                            size: 17,
                                            weight: .semibold))
                                        .foregroundStyle(
                                            .white.opacity(0.55))
                                    Text("Exit challenge")
                                        .font(.system(
                                            size: 15,
                                            weight: .semibold))
                                        .foregroundStyle(.white)
                                    Spacer()
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color.bgSurface)
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 12,
                                        style: .continuous))
                                .overlay(
                                    RoundedRectangle(
                                        cornerRadius: 12,
                                        style: .continuous)
                                        .strokeBorder(
                                            .white.opacity(0.12),
                                            lineWidth: 0.5))
                            }
                            .buttonStyle(.plain)
                            .contentShape(Rectangle())
                        }

                        locationHeader(node: node)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("AT THIS LOCATION")
                                .font(.system(
                                    size: 9, weight: .medium))
                                .foregroundStyle(
                                    .white.opacity(0.28))
                                .kerning(1.2)
                                .textCase(.uppercase)

                            Text(node.insightWord)
                                .font(.system(
                                    size: 28, weight: .bold))
                                .foregroundStyle(.white)

                            Text(node.interpretation)
                                .font(.system(size: 13))
                                .foregroundStyle(
                                    .white.opacity(0.60))
                                .lineSpacing(3)
                        }

                        if !node.whyItMatters.isEmpty {
                            Text(node.whyItMatters)
                                .font(.system(size: 12))
                                .foregroundStyle(
                                    .white.opacity(0.45))
                                .lineSpacing(4)
                                .padding(12)
                                .background(
                                    node.primaryLens.color
                                        .opacity(0.06))
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(
                                            node.primaryLens.color
                                                .opacity(0.12),
                                            lineWidth: 0.5))
                        }

                        LazyVGrid(
                            columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                            ],
                            spacing: 4
                        ) {
                            ForEach(node.envMetrics) { m in
                                LocationMetricCell(
                                    label: m.label,
                                    value: m.value,
                                    color: m.color)
                            }
                        }

                        if !node.trendHistory.isEmpty {
                            VStack(alignment: .leading,
                                   spacing: 8) {
                                Text(
                                    node.historyLabel.isEmpty
                                        ? "Trend · this location"
                                        : node.historyLabel)
                                    .font(.system(
                                        size: 9, weight: .medium))
                                    .foregroundStyle(
                                        .white.opacity(0.28))
                                    .kerning(1.2)
                                    .textCase(.uppercase)
                                ENDOSparkline(
                                    values: node.trendHistory,
                                    color: node.primaryLens.color)
                                    .frame(height: 44)
                            }
                        }

                        Divider()
                            .background(.white.opacity(0.08))

                        bodyResponsePanel(node: node)

                        relatedFactorsBlock(node: node)
                        actionsBlock(node: node)

                        dataProvenanceFooter(node: node)
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
                        .fill(Color.bgSheet.opacity(0.97))
                }
                .clipShape(
                    UnevenRoundedRectangle(
                        cornerRadii: .init(
                            topLeading: 22,
                            bottomLeading: 0,
                            bottomTrailing: 0,
                            topTrailing: 22),
                        style: .continuous))
            } else {
                Color.clear.frame(width: 1, height: 1)
            }
        }
    }

    @ViewBuilder
    private func locationHeader(node: HealthNode) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top,
                   spacing: 14) {
                ZStack {
                    RoundedRectangle(
                        cornerRadius: 14,
                        style: .continuous)
                        .fill(
                            node.primaryLens.color
                                .opacity(0.15))
                        .frame(width: 56,
                               height: 56)
                    Image(
                        systemName: node.type.icon)
                        .font(.system(
                            size: 24,
                            weight: .semibold))
                        .foregroundStyle(
                            node.primaryLens.color)
                }
                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {
                    Text(node.title)
                        .font(.system(
                            size: 20,
                            weight: .bold))
                        .foregroundStyle(.white)
                    Text(node.subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(
                            .white.opacity(0.45))
                }
                Spacer(minLength: 0)
                if let score = node.score {
                    Text("\(score)")
                        .font(.system(
                            size: 15, weight: .bold))
                        .foregroundStyle(
                            node.primaryLens.color)
                        .frame(width: 40, height: 40)
                        .background(
                            node.primaryLens.color
                                .opacity(0.12))
                        .clipShape(Circle())
                        .overlay(
                            Circle().strokeBorder(
                                node.primaryLens.color
                                    .opacity(0.25),
                                lineWidth: 0.5))
                }
            }
            HStack(spacing: 6) {
                Text(node.source)
                    .font(.system(
                        size: 9, weight: .medium))
                    .foregroundStyle(
                        .white.opacity(0.28))
                    .lineLimit(1)
                Text("·")
                    .font(.system(size: 9))
                    .foregroundStyle(
                        .white.opacity(0.22))
                Text(cadenceText(for: node.type.cadence))
                    .font(.system(
                        size: 9, weight: .medium))
                    .foregroundStyle(
                        .white.opacity(0.22))
                    .lineLimit(1)
            }
            .kerning(0.4)
        }
    }

    @ViewBuilder
    private func relatedFactorsBlock(node: HealthNode) -> some View {
        if !node.relatedFactors.isEmpty {
            VStack(
                alignment: .leading,
                spacing: 8
            ) {
                Text("related factors")
                    .font(.system(
                        size: 10, weight: .medium))
                    .foregroundStyle(
                        .white.opacity(0.35))
                    .kerning(1.2)
                    .textCase(.uppercase)
                ScrollView(
                    .horizontal,
                    showsIndicators: false
                ) {
                    HStack(spacing: 7) {
                        ForEach(
                            node.relatedFactors,
                            id: \.self
                        ) { f in
                            Text(f)
                                .font(.system(
                                    size: 12))
                                .foregroundStyle(
                                    .white.opacity(0.60))
                                .padding(
                                    .horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Color.bgSurface)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .strokeBorder(
                                            .white
                                                .opacity(0.10),
                                            lineWidth: 0.5))
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func actionsBlock(node: HealthNode) -> some View {
        VStack(spacing: 8) {
            ForEach(node.actions) { action in
                if action.isPrimary {
                    Button(action.label) {}
                        .primaryCTA()
                        .contentShape(Capsule())
                } else {
                    Button(action.label) {}
                        .secondaryCTA()
                        .contentShape(
                            RoundedRectangle(
                                cornerRadius: 10,
                                style: .continuous))
                }
            }
        }
    }

    @ViewBuilder
    private func bodyResponsePanel(
        node: HealthNode
    ) -> some View {
        VStack(alignment: .leading,
               spacing: 12) {
            HStack {
                Text("BODY RESPONSE")
                    .font(.system(
                        size: 9, weight: .medium))
                    .foregroundStyle(
                        .white.opacity(0.28))
                    .kerning(1.2)
                    .textCase(.uppercase)
                Spacer()
                Text("expected in this zone")
                    .font(.system(size: 8))
                    .foregroundStyle(
                        .white.opacity(0.20))
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ],
                spacing: 4
            ) {
                ForEach(node.bioMetrics) { m in
                    LocationMetricCell(
                        label: m.label,
                        value: m.value,
                        color: m.color)
                }
            }

            if !node.correlationNote.isEmpty {
                HStack(
                    alignment: .top,
                    spacing: 8
                ) {
                    Rectangle()
                        .fill(
                            node.primaryLens.color
                                .opacity(0.55))
                        .frame(width: 2)
                    Text(node.correlationNote)
                        .font(.system(size: 11))
                        .foregroundStyle(
                            .white.opacity(0.48))
                        .lineSpacing(3)
                }
            }

            Text(
                "Based on published research. "
                    + "Individual response varies.")
                .font(.system(size: 9))
                .foregroundStyle(
                    .white.opacity(0.18))
        }
    }

    @ViewBuilder
    private func dataProvenanceFooter(
        node: HealthNode
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 8) {
                if node.type.cadence == .live {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.endoGreen)
                            .frame(width: 5, height: 5)
                        Text("Live")
                            .font(.system(
                                size: 10,
                                weight: .medium))
                            .foregroundStyle(
                                Color.endoGreen.opacity(0.80))
                    }
                } else {
                    Text(cadenceText(
                        for: node.type.cadence))
                        .font(.system(size: 10))
                        .foregroundStyle(
                            .white.opacity(0.22))
                }
                Spacer()
                Text(node.source)
                    .font(.system(size: 10))
                    .foregroundStyle(
                        .white.opacity(0.22))
                    .multilineTextAlignment(.trailing)
            }
            if let refreshed = node.lastRefreshedAt {
                Text(
                    "Updated "
                        + nodeRefreshedCaption(refreshed))
                    .font(.system(size: 9))
                    .foregroundStyle(
                        .white.opacity(0.16))
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 32)
    }
}

private func cadenceText(
    for cadence: NodeCadence
) -> String {
    switch cadence {
    case .live: "Updated hourly"
    case .ephemeral: "Live event data"
    case .permanent: "Updated quarterly"
    }
}

#Preview("Detail · scroll") {
    NodeDetailSheet(node: MockService.nodes()[0])
        .background(Color.bgSheet)
}

#Preview("Detail · in sheet") {
    Color.bgPrimary
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            NodeDetailSheet(node: MockService.nodes()[0])
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.clear)
                .presentationBackgroundInteraction(.disabled)
        }
}

#Preview("No node") {
    NodeDetailSheet(node: nil)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgSheet)
}
