import MapKit
import SwiftUI

struct FriendPreviewCard: View {
    let friend: ENDOFriend
    var onNavigate: () -> Void
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(.white.opacity(0.18))
                .frame(width: 32, height: 3)
                .padding(.top, 10)
                .padding(.bottom, 8)
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(friend.color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Circle()
                        .strokeBorder(
                            friend.color, lineWidth: 2.5)
                        .frame(width: 50, height: 50)
                    Text(friend.initials)
                        .font(.system(
                            size: 15, weight: .bold))
                        .foregroundStyle(friend.color)
                }
                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text(friend.displayName)
                        .font(.system(
                            size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                    HStack(spacing: 5) {
                        Circle()
                            .fill(friend.color)
                            .frame(width: 6, height: 6)
                        Text(friend.zoneText)
                            .font(.system(size: 12))
                            .foregroundStyle(
                                .white.opacity(0.50))
                    }
                    Text(friend.lastSeen,
                         style: .relative)
                        .font(.system(size: 11))
                        .foregroundStyle(
                            .white.opacity(0.25))
                }
                Spacer()
                ZStack {
                    Circle()
                        .strokeBorder(
                            friend.color.opacity(0.20),
                            lineWidth: 5)
                        .frame(width: 44, height: 44)
                    Circle()
                        .trim(
                            from: 0,
                            to: Double(friend.score) / 100)
                        .stroke(
                            friend.color,
                            style: StrokeStyle(
                                lineWidth: 5,
                                lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 44, height: 44)
                    Text("\(friend.score)")
                        .font(.system(
                            size: 11, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 12)

            HStack(spacing: 8) {
                Button(action: onNavigate) {
                    Text("Navigate")
                        .font(.system(
                            size: 12, weight: .semibold))
                        .foregroundStyle(Color.cyanCTA)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.endoCyan)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 10,
                                style: .continuous))
                }
                .buttonStyle(.plain)
                .contentShape(
                    RoundedRectangle(
                        cornerRadius: 10,
                        style: .continuous))

                Button(action: onDismiss) {
                    Text("Dismiss")
                        .font(.system(size: 12))
                        .foregroundStyle(
                            .white.opacity(0.45))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(.white.opacity(0.05))
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 10,
                                style: .continuous))
                        .overlay(
                            RoundedRectangle(
                                cornerRadius: 10,
                                style: .continuous)
                                .strokeBorder(
                                    .white.opacity(0.10),
                                    lineWidth: 0.5))
                }
                .buttonStyle(.plain)
                .contentShape(
                    RoundedRectangle(
                        cornerRadius: 10,
                        style: .continuous))
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
        }
        .background(Color.bgSheet.opacity(0.97))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous))
        .overlay(
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous)
                .strokeBorder(
                    friend.color.opacity(0.22),
                    lineWidth: 0.5))
        .contentShape(Rectangle())
    }
}

#Preview {
    FriendPreviewCard(
        friend: MockService.friends()[0],
        onNavigate: {},
        onDismiss: {})
        .padding()
        .background(Color.bgPrimary)
}

#Preview("In danger") {
    FriendPreviewCard(
        friend: MockService.friends()[1],
        onNavigate: {},
        onDismiss: {})
        .padding()
        .background(Color.bgPrimary)
}
