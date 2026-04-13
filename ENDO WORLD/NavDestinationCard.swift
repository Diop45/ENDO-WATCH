import SwiftUI

/// Destination context during navigation.
struct NavDestinationCard: View {
    let nav: NavigationModel
    var onPing: (() -> Void)? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                destinationIcon
                VStack(alignment: .leading,
                       spacing: 3) {
                    Text(nav.destinationTitle)
                        .font(.system(
                            size: 13,
                            weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(nav.destinationSubtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(
                            .white.opacity(0.45))
                        .lineLimit(1)
                }
                Spacer()
                Text(nav.destinationMetricValue)
                    .font(.system(
                        size: 11,
                        weight: .bold))
                    .foregroundStyle(
                        nav.destinationMetricColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        nav.destinationColor
                            .opacity(0.12))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().strokeBorder(
                            nav.destinationColor
                                .opacity(0.25),
                            lineWidth: 0.5))
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 8)

            if let node = nav.destinationNode {
                nodeEnvMetricRow(node)
                nodeBioMetricRow(node)
            }

            if let friend = nav.destinationFriend {
                friendMetricRow(friend)
            }

            Text(nav.proximityNote)
                .font(.system(size: 10))
                .foregroundStyle(
                    nav.state == .arrived
                        ? nav.destinationColor
                        : .white.opacity(0.38))
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity,
                       alignment: .center)

            actionButton
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
        }
        .background(Color.bgSheet.opacity(0.97))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous))
        .overlay(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous)
                .strokeBorder(
                    nav.destinationColor.opacity(0.20),
                    lineWidth: 0.5))
    }

    @ViewBuilder
    private var destinationIcon: some View {
        if let node = nav.destinationNode {
            ZStack {
                RoundedRectangle(cornerRadius: 9)
                    .fill(
                        node.primaryLens.color
                            .opacity(0.15))
                    .frame(width: 38, height: 38)
                RoundedRectangle(cornerRadius: 9)
                    .strokeBorder(
                        node.primaryLens.color
                            .opacity(0.35),
                        lineWidth: 0.5)
                    .frame(width: 38, height: 38)
                Image(systemName: node.type.icon)
                    .font(.system(
                        size: 16, weight: .semibold))
                    .foregroundStyle(
                        node.primaryLens.color)
            }
        } else if let friend = nav.destinationFriend {
            ZStack {
                Circle()
                    .fill(
                        friend.color.opacity(0.15))
                    .frame(width: 38, height: 38)
                Circle()
                    .strokeBorder(
                        friend.color.opacity(0.55),
                        lineWidth: 0.5)
                    .frame(width: 38, height: 38)
                Text(friend.initials)
                    .font(.system(
                        size: 13, weight: .bold))
                    .foregroundStyle(friend.color)
            }
        }
    }

    @ViewBuilder
    private func nodeEnvMetricRow(
        _ node: HealthNode
    ) -> some View {
        HStack(spacing: 4) {
            ForEach(node.envMetrics.prefix(2)) { m in
                navMetricCell(
                    label: m.label,
                    value: m.value,
                    valueColor: m.color)
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private func nodeBioMetricRow(
        _ node: HealthNode
    ) -> some View {
        if !node.bioMetrics.isEmpty {
            HStack(spacing: 4) {
                ForEach(node.bioMetrics.prefix(2)) { m in
                    navMetricCell(
                        label: m.label,
                        value: m.value,
                        valueColor: m.color)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 6)
        }
    }

    private func navMetricCell(
        label: String,
        value: String,
        valueColor: Color
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 2
        ) {
            Text(label)
                .font(.system(
                    size: 8, weight: .medium))
                .foregroundStyle(
                    .white.opacity(0.28))
                .textCase(.uppercase)
            Text(value)
                .font(.system(
                    size: 13,
                    weight: .bold))
                .foregroundStyle(valueColor)
        }
        .frame(maxWidth: .infinity,
               alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.bgElevated)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 6))
    }

    @ViewBuilder
    private func friendMetricRow(
        _ friend: ENDOFriend
    ) -> some View {
        HStack(spacing: 4) {
            VStack(
                alignment: .leading,
                spacing: 2
            ) {
                Text("Zone")
                    .font(.system(
                        size: 8, weight: .medium))
                    .foregroundStyle(
                        .white.opacity(0.28))
                    .textCase(.uppercase)
                Text(friend.zone.rawValue)
                    .font(.system(
                        size: 12,
                        weight: .bold))
                    .foregroundStyle(
                        friend.zone.color)
            }
            .frame(maxWidth: .infinity,
                   alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.bgElevated)
            .clipShape(
                RoundedRectangle(cornerRadius: 6))

            VStack(
                alignment: .leading,
                spacing: 2
            ) {
                Text("Score")
                    .font(.system(
                        size: 8, weight: .medium))
                    .foregroundStyle(
                        .white.opacity(0.28))
                    .textCase(.uppercase)
                Text("\(friend.score)")
                    .font(.system(
                        size: 12,
                        weight: .bold))
                    .foregroundStyle(friend.color)
            }
            .frame(maxWidth: .infinity,
                   alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.bgElevated)
            .clipShape(
                RoundedRectangle(cornerRadius: 6))

            Text("Moving")
                .font(.system(
                    size: 9, weight: .medium))
                .foregroundStyle(
                    .white.opacity(0.55))
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.bgElevated)
                .clipShape(
                    RoundedRectangle(cornerRadius: 6))
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 6)
    }

    @ViewBuilder
    private var actionButton: some View {
        if nav.state == .arrived {
            if nav.destinationNode != nil {
                Button("Scan zone · +10 XP") {
                    onAction?()
                }
                .font(.system(
                    size: 13, weight: .semibold))
                .foregroundStyle(
                    scanArrivedForeground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(nav.destinationColor)
                .clipShape(Capsule())
                .contentShape(Capsule())
            } else if let friend = nav.destinationFriend {
                Button(
                    "You found \(friend.displayName)"
                ) {
                    onAction?()
                }
                .font(.system(
                    size: 13, weight: .semibold))
                .foregroundStyle(
                    Color(hex: "#173404"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(friend.color)
                .clipShape(Capsule())
                .contentShape(Capsule())
            }
        } else if nav.destinationFriend != nil {
            Button("Ping") {
                onPing?()
            }
            .font(.system(
                size: 13, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(Color.bgSurface)
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(
                    .white.opacity(0.15),
                    lineWidth: 0.5))
            .contentShape(Capsule())
        } else {
            Button("End route") {
                onAction?()
            }
            .font(.system(size: 12))
            .foregroundStyle(
                .white.opacity(0.45))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(Color.bgSurface)
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(
                    .white.opacity(0.10),
                    lineWidth: 0.5))
            .contentShape(Capsule())
        }
    }

    private var scanArrivedForeground: Color {
        guard let n = nav.destinationNode else {
            return Color.cyanCTA
        }
        if n.primaryLens == .care || n.type.isPositive {
            return Color(hex: "#173404")
        }
        return Color.cyanCTA
    }
}

@MainActor
private func previewNavigation(
    state: NavState,
    destination: NavDestinationType
) -> NavigationModel {
    let nav = NavigationModel()
    nav.state = state
    nav.destination = destination
    return nav
}

#Preview("Node · en route") {
    NavDestinationCard(
        nav: previewNavigation(
            state: .active,
            destination: .zone(MockService.nodes()[0])))
        .padding()
        .background(Color.bgPrimary)
}

#Preview("Node · arrived") {
    NavDestinationCard(
        nav: previewNavigation(
            state: .arrived,
            destination: .zone(MockService.nodes()[0])))
        .padding()
        .background(Color.bgPrimary)
}

#Preview("Friend") {
    NavDestinationCard(
        nav: previewNavigation(
            state: .active,
            destination: .friend(MockService.friends()[0])))
        .padding()
        .background(Color.bgPrimary)
}

