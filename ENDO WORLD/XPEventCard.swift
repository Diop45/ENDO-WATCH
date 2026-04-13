import SwiftUI

struct XPEventCard: View {
    let xp: Int
    let isMutual: Bool
    let isHostile: Bool

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        Color.endoCyan.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: "bolt.fill")
                    .font(.system(
                        size: 13, weight: .semibold))
                    .foregroundStyle(Color.endoCyan)
            }
            VStack(alignment: .leading,
                   spacing: 2) {
                Text("+\(xp) XP")
                    .font(.system(
                        size: 14, weight: .bold))
                    .foregroundStyle(Color.endoCyan)
                Text(eventLabel)
                    .font(.system(size: 10))
                    .foregroundStyle(
                        .white.opacity(0.50))
            }
            Spacer()
        }
        .padding(.horizontal, 14)
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
                    Color.endoCyan.opacity(0.25),
                    lineWidth: 0.5))
    }

    private var eventLabel: String {
        if isMutual && isHostile {
            return "Mutual scan · hostile zone · 1.5x"
        } else if isMutual {
            return "Mutual scan completed"
        } else if isHostile {
            return "Hostile zone scanned"
        }
        return "Zone scanned"
    }
}

#Preview("Mutual · hostile") {
    XPEventCard(xp: 45, isMutual: true, isHostile: true)
        .padding()
        .background(Color.bgPrimary)
}

#Preview("Mutual") {
    XPEventCard(xp: 20, isMutual: true, isHostile: false)
        .padding()
        .background(Color.bgPrimary)
}

#Preview("Solo") {
    XPEventCard(xp: 10, isMutual: false, isHostile: false)
        .padding()
        .background(Color.bgPrimary)
}
