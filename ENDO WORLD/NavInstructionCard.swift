import SwiftUI

struct NavInstructionCard: View {
    let nav: NavigationModel

    var body: some View {
        HStack(spacing: 10) {
            directionCircle

            VStack(alignment: .leading,
                   spacing: 3) {
                if nav.state == .arrived {
                    Text("Arrived.")
                        .font(.system(
                            size: 18,
                            weight: .bold))
                        .foregroundStyle(
                            nav.destinationColor)
                } else {
                    HStack(
                        alignment: .firstTextBaseline,
                        spacing: 3
                    ) {
                        Text(formattedDistance)
                            .font(.system(
                                size: 22,
                                weight: .bold))
                            .foregroundStyle(.white)
                        Text(distanceUnit)
                            .font(.system(size: 10))
                            .foregroundStyle(
                                .white.opacity(0.40))
                    }
                }
                Text(nav.instruction)
                    .font(.system(
                        size: 12,
                        weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing,
                   spacing: 2) {
                Text(nav.destinationMetricValue)
                    .font(.system(
                        size: 13,
                        weight: .bold))
                    .foregroundStyle(
                        nav.destinationMetricColor)
                Text(nav.destinationMetricLabel)
                    .font(.system(size: 8))
                    .foregroundStyle(
                        .white.opacity(0.35))
                    .multilineTextAlignment(.trailing)
                Text("Live")
                    .font(.system(
                        size: 8,
                        weight: .medium))
                    .foregroundStyle(Color.endoCyan)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
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
                    nav.destinationColor.opacity(
                        nav.state == .arrived
                            ? 0.50 : 0.25),
                    lineWidth: 0.5))
        .contentShape(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous))
    }

    private var directionCircle: some View {
        ZStack {
            Circle()
                .fill(Color.bgSheet.opacity(0.9))
                .frame(width: 46, height: 46)
            Circle()
                .strokeBorder(
                    nav.state == .arrived
                        ? nav.destinationColor
                        : Color.endoCyan.opacity(0.50),
                    lineWidth: 0.5)
                .frame(width: 46, height: 46)

            if nav.state == .arrived {
                Image(systemName: "checkmark")
                    .font(.system(
                        size: 16,
                        weight: .bold))
                    .foregroundStyle(
                        nav.destinationColor)
            } else {
                Image(systemName: "arrow.up")
                    .font(.system(
                        size: 18,
                        weight: .semibold))
                    .foregroundStyle(
                        Color.endoCyan)
                    .rotationEffect(
                        .degrees(nav.directionAngle))
                    .animation(
                        .easeInOut(duration: 0.35),
                        value: nav.directionAngle)
            }
        }
    }

    private var formattedDistance: String {
        let d = nav.distanceToDestination
        if d >= 1609 {
            let miles = d / 1609
            return String(format: "%.1f", miles)
        } else if d >= 91 {
            let feet = Int(d * 3.281)
            let rounded = (feet / 50) * 50
            return "\(rounded)"
        } else {
            let feet = Int(d * 3.281)
            return "\(feet)"
        }
    }

    private var distanceUnit: String {
        let d = nav.distanceToDestination
        if d >= 1609 { return "mi" }
        return "ft"
    }
}

@MainActor
private func previewNavInstruction(
    state: NavState,
    distance: Double,
    angle: Double
) -> NavigationModel {
    let nav = NavigationModel()
    nav.state = state
    nav.destination = .zone(MockService.nodes()[0])
    nav.instruction = "Head north on Woodward Ave"
    nav.distanceToDestination = distance
    nav.directionAngle = angle
    return nav
}

#Preview("En route") {
    NavInstructionCard(
        nav: previewNavInstruction(
            state: .active,
            distance: 420,
            angle: 18))
        .padding()
        .background(Color.bgPrimary)
}

#Preview("Arrived") {
    NavInstructionCard(
        nav: previewNavInstruction(
            state: .arrived,
            distance: 0,
            angle: 0))
        .padding()
        .background(Color.bgPrimary)
}
