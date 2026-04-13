import SwiftUI

struct IncomingRequestBanner: View {
    let user: AnonUser
    var onAccept: () -> Void
    var onIgnore: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#252528"))
                    .frame(width: 36, height: 36)
                Circle()
                    .strokeBorder(
                        user.zoneSignal.ringColor,
                        lineWidth: 0.5)
                    .frame(width: 36, height: 36)
                Image(systemName: "person.fill")
                    .font(.system(
                        size: 14, weight: .medium))
                    .foregroundStyle(
                        Color(hex: "#888780"))
                if user.role.isMapper {
                    Circle()
                        .fill(Color.endoCyan)
                        .frame(width: 7, height: 7)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    Color(hex: "#252528"),
                                    lineWidth: 0.5))
                        .offset(x: 13, y: -13)
                }
            }

            VStack(alignment: .leading,
                   spacing: 2) {
                Text(user.requestCardTitle)
                    .font(.system(
                        size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                Text(user.requestCardSubtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(
                        .white.opacity(0.45))
                    .lineLimit(1)
            }

            Spacer()

            Button("Accept") {
                onAccept()
            }
            .font(.system(
                size: 11, weight: .semibold))
            .foregroundStyle(Color.cyanCTA)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.endoCyan)
            .clipShape(Capsule())
            .buttonStyle(.plain)
            .contentShape(Capsule())

            Button(action: onIgnore) {
                Image(systemName: "xmark")
                    .font(.system(
                        size: 10, weight: .medium))
                    .foregroundStyle(
                        .white.opacity(0.35))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.bgSheet.opacity(0.95))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 12,
                style: .continuous))
        .overlay(
            RoundedRectangle(
                cornerRadius: 12,
                style: .continuous)
                .strokeBorder(
                    Color.endoCyan.opacity(0.20),
                    lineWidth: 0.5))
    }
}

#Preview {
    IncomingRequestBanner(
        user: AnonUser(
            id: "r",
            coordinate: .init(latitude: 42.33, longitude: -83.05),
            state: .requestReceived,
            zoneSignal: .moderate,
            activeLens: .all,
            role: .mapper,
            distanceMeters: 150),
        onAccept: {},
        onIgnore: {})
        .padding()
        .background(Color.bgPrimary)
}
