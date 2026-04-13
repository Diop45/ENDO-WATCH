import SwiftUI

/// Brief pill when another anonymous user enters the one-mile radius.
struct RadiusEntryToast: View {
    let user: AnonUser

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(user.zoneSignal.ringColor)
                .frame(width: 6, height: 6)
            Text(
                user.role.isMapper
                    ? "Mapper entered your area"
                    : "ENDO user entered your area")
                .font(.system(
                    size: 10, weight: .medium))
                .foregroundStyle(
                    .white.opacity(0.65))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.bgSheet.opacity(0.90))
        .clipShape(Capsule())
        .overlay(
            Capsule().strokeBorder(
                user.zoneSignal.ringColor
                    .opacity(0.30),
                lineWidth: 0.5))
    }
}

#Preview("Mapper") {
    RadiusEntryToast(
        user: AnonUser(
            id: "1",
            coordinate: .init(latitude: 42.33, longitude: -83.05),
            state: .entered,
            zoneSignal: .moderate,
            activeLens: .all,
            role: .mapper,
            distanceMeters: 200))
        .padding()
        .background(Color.bgPrimary)
}

#Preview("Scout") {
    RadiusEntryToast(
        user: AnonUser(
            id: "2",
            coordinate: .init(latitude: 42.33, longitude: -83.05),
            state: .entered,
            zoneSignal: .hostile,
            activeLens: .outcome,
            role: .scout,
            distanceMeters: 400))
        .padding()
        .background(Color.bgPrimary)
}
