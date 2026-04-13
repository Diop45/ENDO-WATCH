import SwiftUI

struct MapIntroExplainerView: View {
    @Environment(AppState.self) private var appState

    private static let items: [(
        icon: String,
        title: String,
        detail: String
    )] = [
        (
            icon: "person.crop.circle.fill",
            title: "Top bar",
            detail:
                "Profile opens your biometric cluster (HR, HRV, SpO₂, breathing) and friend-pin toggles. When the health layer is on, the HR / HRV / SpO₂ / RR pills scroll beside it and the Lens chip filters nodes by category."
        ),
        (
            icon: "location.fill",
            title: "Recenter",
            detail:
                "Returns the camera to the demo Detroit view after you pan or zoom the map."
        ),
        (
            icon: "dot.radiowaves.left.and.right",
            title: "Health scan",
            detail:
                "Toggles the cyan scan ripple and node pins. Use Lens on the top bar to filter. Tap a teal pin for the node preview card; drag up or use the primary action for full detail."
        ),
        (
            icon: "scope",
            title: "Mission sample",
            detail:
                "Opens or closes a compact mission-style banner (demo copy) so you can see how in-map prompts look."
        ),
        (
            icon: "link.circle.fill",
            title: "Nearby ENDO users",
            detail:
                "Shows anonymized nearby presence in the demo; the badge counts visible users. Tap again to turn the layer off."
        ),
        (
            icon: "ellipsis",
            title: "Demo menu",
            detail:
                "Runs preset scenarios (same as the old use-case panel) or simulates an incoming scan request."
        ),
        (
            icon: "mappin.circle.fill",
            title: "Pins & bottom bar",
            detail:
                "Teal-accent pins are nodes; rings and labels intensify as you get closer in the demo walk. Tap empty map space to dismiss cards. The bottom strip is a live public-health ticker (air, particles, heat, noise, area index) that rotates every few seconds when no sheet is open."
        ),
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {}

            VStack(spacing: 0) {
                Text("How this map works")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 4)

                Text("Top bar & right rail")
                    .capsLabel()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 12)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(
                            Array(Self.items.enumerated()),
                            id: \.offset
                        ) { _, item in
                            explainerRow(
                                icon: item.icon,
                                title: item.title,
                                detail: item.detail)
                        }
                    }
                }
                .frame(maxHeight: 420)

                Button {
                    appState.acknowledgeMapIntro()
                } label: {
                    Text("Got it")
                }
                .primaryCTA()
                .padding(.top, 16)
                .contentShape(Capsule())
            }
            .padding(20)
            .background(Color.bgSheet.opacity(0.98))
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous))
            .overlay(
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous)
                    .strokeBorder(
                        Color.endoCyan.opacity(0.22),
                        lineWidth: 0.5))
            .padding(.horizontal, 16)
            .padding(.vertical, 28)
        }
    }

    private func explainerRow(
        icon: String,
        title: String,
        detail: String
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.bgSurface)
                    .frame(width: 44, height: 44)
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        .white.opacity(0.12),
                        lineWidth: 0.5)
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.endoCyan)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color.bgSurface.opacity(0.6))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 12,
                style: .continuous))
        .overlay(
            RoundedRectangle(
                cornerRadius: 12,
                style: .continuous)
                .strokeBorder(
                    .white.opacity(0.08),
                    lineWidth: 0.5))
    }
}

#Preview {
    MapIntroExplainerView()
        .environment(AppState())
}
