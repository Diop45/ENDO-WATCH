import SwiftUI

struct FriendAnnotationView: View {
    let friend: ENDOFriend
    let onTap: () -> Void
    @State private var pulsing = false

    var body: some View {
        Button(action: onTap) {
            ZStack {
                if friend.isInDanger {
                    Circle()
                        .strokeBorder(
                            Color.endoRed.opacity(
                                pulsing ? 0 : 0.4),
                            lineWidth: 1.5)
                        .frame(width: 54, height: 54)
                        .scaleEffect(
                            pulsing ? 1.3 : 1.0)
                        .animation(
                            .easeOut(duration: 1.2)
                                .repeatForever(
                                    autoreverses: false),
                            value: pulsing)
                }
                ZStack {
                    Circle()
                        .fill(
                            friend.color.opacity(0.18))
                        .frame(width: 40, height: 40)
                    Circle()
                        .strokeBorder(
                            friend.color,
                            lineWidth: 2.5)
                        .frame(width: 40, height: 40)
                    Text(friend.initials)
                        .font(.system(
                            size: 13, weight: .bold))
                        .foregroundStyle(friend.color)
                }
                Text("\(friend.score)")
                    .font(.system(
                        size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(friend.color)
                    .clipShape(Capsule())
                    .offset(x: 14, y: 14)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 56, height: 56)
        .contentShape(Rectangle())
        .onAppear {
            if friend.isInDanger {
                pulsing = true
            }
        }
    }
}

#Preview("Supportive") {
    FriendAnnotationView(
        friend: MockService.friends()[0],
        onTap: {})
        .padding(40)
        .background(Color.bgPrimary)
}

#Preview("Hostile pulse") {
    FriendAnnotationView(
        friend: MockService.friends()[1],
        onTap: {})
        .padding(40)
        .background(Color.bgPrimary)
}
