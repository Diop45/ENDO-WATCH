import SwiftUI

/// Anonymous user dot: neutral body, zone ring, distance-aware opacity/size.
struct AnonUserAnnotationView: View {
    let user: AnonUser
    let onTap: () -> Void
    @State private var pulsing = false

    private var showsZoneRing: Bool {
        user.state == .visible
            || user.state == .requestSent
            || user.state == .requestReceived
            || user.state == .entered
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                if user.proximityBand == .near
                    || user.proximityBand == .close
                {
                    Circle()
                        .strokeBorder(
                            user.zoneSignal.ringColor
                                .opacity(
                                    pulsing ? 0 : 0.6),
                            lineWidth: 0.5)
                        .frame(
                            width: user.dotSize + 16,
                            height: user.dotSize + 16)
                        .scaleEffect(
                            pulsing ? 1.25 : 1.0)
                        .animation(
                            .easeOut(duration: 1.8)
                                .repeatForever(
                                    autoreverses: false),
                            value: pulsing)
                }

                if user.state == .scanning {
                    Circle()
                        .strokeBorder(
                            Color.endoCyan.opacity(
                                pulsing ? 0.15 : 0.65),
                            lineWidth: 0.5)
                        .frame(
                            width: user.dotSize + 20,
                            height: user.dotSize + 20)
                        .scaleEffect(
                            pulsing ? 1.35 : 1.0)
                        .animation(
                            .easeOut(duration: 1.4)
                                .repeatForever(
                                    autoreverses: false),
                            value: pulsing)
                }

                if showsZoneRing,
                   user.state != .scanning
                {
                    Circle()
                        .strokeBorder(
                            user.zoneSignal.ringColor,
                            lineWidth: 0.5)
                        .frame(
                            width: user.dotSize + 6,
                            height: user.dotSize + 6)
                }

                ZStack {
                    Circle()
                        .fill(Color(hex: "#1D1D21"))
                        .frame(
                            width: user.dotSize,
                            height: user.dotSize)
                    Circle()
                        .strokeBorder(
                            Color(hex: "#888780")
                                .opacity(0.55),
                            lineWidth: 0.5)
                        .frame(
                            width: user.dotSize,
                            height: user.dotSize)

                    Image(systemName: "person.fill")
                        .font(.system(
                            size: user.dotSize * 0.42,
                            weight: .medium))
                        .foregroundStyle(
                            Color(hex: "#888780"))

                    if user.role.isMapper {
                        Circle()
                            .fill(Color.endoCyan)
                            .frame(width: 7, height: 7)
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        Color(hex: "#1D1D21"),
                                        lineWidth: 0.5))
                            .offset(
                                x: user.dotSize * 0.38,
                                y: -user.dotSize * 0.38)
                    }

                    if user.state == .requestSent {
                        Circle()
                            .fill(
                                Color.endoCyan.opacity(0.15))
                            .frame(
                                width: user.dotSize,
                                height: user.dotSize)
                        Image(systemName:
                            "arrow.up.circle.fill")
                            .font(.system(
                                size: user.dotSize * 0.40))
                            .foregroundStyle(
                                Color.endoCyan.opacity(0.7))
                    }
                }
                .opacity(user.dotOpacity)
                .scaleEffect(
                    user.state == .scanning
                        ? 1.1 : 1.0)
                .animation(
                    .easeInOut(duration: 2.0),
                    value: user.state)

                if user.proximityBand == .close,
                   user.state == .visible
                {
                    Text(user.formattedDistance)
                        .font(.system(
                            size: 7, weight: .medium))
                        .foregroundStyle(
                            Color(hex: "#888780")
                                .opacity(0.60))
                        .offset(
                            y: user.dotSize / 2 + 6)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(
            width: user.dotSize + 28,
            height: user.dotSize + 28)
        .contentShape(Circle())
        .onAppear { pulsing = true }
    }
}

#Preview("Visible · close") {
    AnonUserAnnotationView(
        user: AnonUser(
            id: "a",
            coordinate: .init(latitude: 42.33, longitude: -83.05),
            state: .visible,
            zoneSignal: .supportive,
            activeLens: .care,
            role: .mapper,
            distanceMeters: 80),
        onTap: {})
        .padding(40)
        .background(Color.bgPrimary)
}

#Preview("Scanning") {
    AnonUserAnnotationView(
        user: AnonUser(
            id: "b",
            coordinate: .init(latitude: 42.33, longitude: -83.05),
            state: .scanning,
            zoneSignal: .moderate,
            activeLens: .all,
            role: .scout,
            distanceMeters: 200),
        onTap: {})
        .padding(40)
        .background(Color.bgPrimary)
}
