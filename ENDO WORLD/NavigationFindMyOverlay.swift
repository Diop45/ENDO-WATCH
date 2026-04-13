import SwiftUI

/// Find My–style bottom sheet during walking navigation (MapKit route + Apple Maps handoff).
struct NavigationFindMyOverlay: View {
    @Bindable var vm: MapViewModel

    private var nav: NavigationModel { vm.nav }

    private var navSheetShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            cornerRadii: .init(
                topLeading: 32,
                bottomLeading: 0,
                bottomTrailing: 0,
                topTrailing: 32),
            style: .continuous)
    }

    var body: some View {
        VStack(spacing: 0) {
            if vm.navBannerVisible {
                ZoneEntryBanner(
                    zone: vm.navBannerZone,
                    signal: navBannerSignal,
                    navActive: true)
                    .padding(.horizontal, 14)
                    .padding(.top, 10)
                    .padding(.bottom, 4)
            }

            instructionRow
                .padding(.horizontal, 16)
                .padding(.top, vm.navBannerVisible ? 4 : 14)
                .padding(.bottom, 12)

            heroSection
                .padding(.bottom, 8)

            Text(nav.proximityNote)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

            VStack(spacing: 8) {
                primaryAction
                Button {
                    vm.openAppleMapsWalkingDirections()
                } label: {
                    Text("Open in Apple Maps")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
        .background {
            navSheetShape
                .fill(.ultraThinMaterial)
        }
        .clipShape(navSheetShape)
        .overlay(
            navSheetShape
                .strokeBorder(
                    Color.white.opacity(0.12),
                    lineWidth: 0.5))
    }

    private var navBannerSignal: String {
        guard let node = nav.destinationNode else { return "" }
        return "\(node.envMetricValue) · \(node.envMetricLabel)"
    }

    private var instructionRow: some View {
        HStack(alignment: .center, spacing: 14) {
            directionDial
                .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 4) {
                if nav.state == .arrived {
                    Text("Arrived")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(nav.destinationColor)
                } else {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(formattedPrimaryDistance)
                            .font(.system(
                                size: 28,
                                weight: .bold,
                                design: .rounded))
                            .foregroundStyle(.primary)
                        Text(primaryDistanceUnit)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                Text(nav.instruction)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 4) {
                Image(systemName: "location.north.line.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text("Live")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color(red: 0, green: 0.78, blue: 1))
            }
            .frame(width: 44)
        }
    }

    private var directionDial: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.25))
            Circle()
                .strokeBorder(
                    Color.white.opacity(0.2),
                    lineWidth: 0.5)
            if nav.state == .arrived {
                Image(systemName: "checkmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(nav.destinationColor)
            } else {
                Image(systemName: "arrow.up")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(nav.directionAngle))
                    .animation(
                        .easeInOut(duration: 0.35),
                        value: nav.directionAngle)
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 10) {
            heroAvatar
                .shadow(
                    color: .black.opacity(0.35),
                    radius: 12,
                    y: 6)

            VStack(spacing: 4) {
                Text(nav.destinationTitle)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                Text(nav.destinationSubtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.horizontal, 16)

            statusPill
        }
    }

    @ViewBuilder
    private var heroAvatar: some View {
        if let friend = nav.destinationFriend {
            Text(friend.initials)
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 88, height: 88)
                .background(
                    Circle()
                        .fill(friend.color.opacity(0.42)))
                .overlay(
                    Circle()
                        .strokeBorder(
                            Color.white.opacity(0.35),
                            lineWidth: 2))
        } else if let node = nav.destinationNode {
            Image(systemName: node.type.icon)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 88, height: 88)
                .background(
                    Circle()
                        .fill(
                            node.primaryLens.color.opacity(0.38)))
                .overlay(
                    Circle()
                        .strokeBorder(
                            Color.white.opacity(0.35),
                            lineWidth: 2))
        }
    }

    private var statusPill: some View {
        HStack(spacing: 6) {
            if let friend = nav.destinationFriend {
                Text(friend.zone.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                Text("·")
                    .foregroundStyle(.tertiary)
                Text("Moving")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            } else if let node = nav.destinationNode {
                Text(node.title)
                    .font(.system(size: 11, weight: .semibold))
                    .lineLimit(1)
                Text("·")
                    .foregroundStyle(.tertiary)
                Text(node.envMetricValue)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(node.envMetricColor)
            }
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(Color.primary.opacity(0.08)))
        .overlay(
            Capsule()
                .strokeBorder(
                    Color.white.opacity(0.12),
                    lineWidth: 0.5))
    }

    @ViewBuilder
    private var primaryAction: some View {
        if nav.state == .arrived {
            if nav.destinationNode != nil {
                arrivedZoneButton
            } else if let friend = nav.destinationFriend {
                Button {
                    vm.endNavigation()
                } label: {
                    Text("You found \(friend.displayName)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(hex: "#173404"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(friend.color)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        } else if nav.destinationFriend != nil {
            Button {
                if let f = nav.destinationFriend {
                    vm.pingFriend(f)
                }
            } label: {
                Text("Ping sound")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.88))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        } else {
            Button {
                vm.endNavigation()
            } label: {
                Text("End route")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.primary.opacity(0.12))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var arrivedZoneButton: some View {
        if let n = nav.destinationNode {
            let fg: Color =
                (n.primaryLens == .care || n.type.isPositive)
                ? Color(hex: "#173404")
                : Color.cyanCTA
            Button {
                vm.endNavigation()
            } label: {
                Text("Scan zone · +10 XP")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(fg)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(n.primaryLens.color)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private var formattedPrimaryDistance: String {
        let d = nav.distanceToDestination
        if nav.state == .arrived { return "0" }
        if d >= 1609 {
            return String(format: "%.1f", d / 1609)
        } else if d >= 91 {
            let feet = Int(d * 3.281)
            let rounded = (feet / 50) * 50
            return "\(rounded)"
        } else {
            return "\(Int(d * 3.281))"
        }
    }

    private var primaryDistanceUnit: String {
        let d = nav.distanceToDestination
        if nav.state == .arrived { return "ft" }
        if d >= 1609 { return "mi" }
        return "ft"
    }
}
