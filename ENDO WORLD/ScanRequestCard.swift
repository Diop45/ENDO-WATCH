import SwiftUI

/// Card when tapping an anonymous dot. No identifying information.
struct ScanRequestCard: View {
    let user: AnonUser
    var onSendRequest: () -> Void
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.white.opacity(0.18))
                .frame(width: 28, height: 3)
                .padding(.top, 10)
                .padding(.bottom, 10)

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#252528"))
                        .frame(width: 44, height: 44)
                    Circle()
                        .strokeBorder(
                            user.zoneSignal.ringColor,
                            lineWidth: 0.5)
                        .frame(width: 44, height: 44)
                    Image(systemName: "person.fill")
                        .font(.system(
                            size: 18, weight: .medium))
                        .foregroundStyle(
                            Color(hex: "#888780"))
                    if user.role.isMapper {
                        Circle()
                            .fill(Color.endoCyan)
                            .frame(width: 8, height: 8)
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        Color(hex: "#252528"),
                                        lineWidth: 0.5))
                            .offset(x: 16, y: -16)
                    }
                }

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text(user.requestCardTitle)
                        .font(.system(
                            size: 13,
                            weight: .semibold))
                        .foregroundStyle(.white)
                    Text(user.requestCardSubtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(
                            .white.opacity(0.50))
                    Text(user.activeLens.rawValue + " lens")
                        .font(.system(
                            size: 9, weight: .medium))
                        .foregroundStyle(
                            user.activeLens.color)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            user.activeLens.color
                                .opacity(0.12))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().strokeBorder(
                                user.activeLens.color
                                    .opacity(0.25),
                                lineWidth: 0.5))
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(
                            size: 11, weight: .medium))
                        .foregroundStyle(
                            .white.opacity(0.30))
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 12)

            Button(action: onSendRequest) {
                HStack(spacing: 8) {
                    Image(systemName:
                        "antenna.radiowaves.left.and.right")
                        .font(.system(size: 13))
                    Text("Send scan request")
                        .font(.system(
                            size: 13,
                            weight: .semibold))
                }
                .foregroundStyle(Color.cyanCTA)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(Color.endoCyan)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .contentShape(Capsule())
            .padding(.horizontal, 14)

            Text(
                "Only your zone and active lens are shared. No personal data.")
                .font(.system(size: 9))
                .foregroundStyle(
                    .white.opacity(0.25))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 14)
                .padding(.top, 6)
                .padding(.bottom, 12)
        }
        .background(Color.bgSheet.opacity(0.97))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous))
        .overlay(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous)
                .strokeBorder(
                    .white.opacity(0.10),
                    lineWidth: 0.5))
    }
}

#Preview("Mapper") {
    ScanRequestCard(
        user: AnonUser(
            id: "m",
            coordinate: .init(latitude: 42.33, longitude: -83.05),
            state: .visible,
            zoneSignal: .supportive,
            activeLens: .care,
            role: .mapper,
            distanceMeters: 120),
        onSendRequest: {},
        onDismiss: {})
        .padding()
        .background(Color.bgPrimary)
}

#Preview("Scout") {
    ScanRequestCard(
        user: AnonUser(
            id: "s",
            coordinate: .init(latitude: 42.33, longitude: -83.05),
            state: .visible,
            zoneSignal: .moderate,
            activeLens: .all,
            role: .scout,
            distanceMeters: 800),
        onSendRequest: {},
        onDismiss: {})
        .padding()
        .background(Color.bgPrimary)
}
