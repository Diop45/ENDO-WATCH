import SwiftUI

struct ChallengeInviteCard: View {
    let node: HealthNode
    let onJoin: () -> Void
    let onDecline: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Community challenge")
                    .capsLabel()
                Spacer()
                Button(action: onDecline) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.45))
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 6)

            Text(node.title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)

            Text(
                "Join to track this challenge on the map. Until then, proximity alerts stay off."
            )
            .font(.system(size: 13))
            .foregroundStyle(.white.opacity(0.52))
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 16)

            Button(action: onJoin) {
                Text("Join challenge")
            }
            .primaryCTA()
            .contentShape(Capsule())

            Button(action: onDecline) {
                Text("Not now")
            }
            .secondaryCTA()
            .padding(.top, 10)
            .contentShape(
                RoundedRectangle(
                    cornerRadius: 10,
                    style: .continuous))
        }
        .padding(18)
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
                    node.primaryLens.color.opacity(0.28),
                    lineWidth: 0.5))
    }
}

#Preview {
    ZStack {
        Color.bgPrimary.ignoresSafeArea()
        ChallengeInviteCard(
            node: MockService.nodes().first(where: { $0.id == "n11" })
                ?? MockService.nodes()[0],
            onJoin: {},
            onDecline: {})
    }
}
