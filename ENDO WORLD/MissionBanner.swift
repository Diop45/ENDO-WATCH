import SwiftUI

struct MissionBanner: View {
    let title: String
    let missionBody: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.endoCyan.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: "bolt.fill")
                    .font(.system(
                        size: 13, weight: .semibold))
                    .foregroundStyle(Color.endoCyan)
            }

            VStack(alignment: .leading,
                   spacing: 2) {
                Text(title)
                    .font(.system(
                        size: 11, weight: .semibold))
                    .foregroundStyle(Color.endoCyan)
                    .lineLimit(1)
                Text(missionBody)
                    .font(.system(size: 11))
                    .foregroundStyle(
                        .white.opacity(0.55))
                    .lineLimit(2)
                    .lineSpacing(2)
            }

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(
                        size: 10, weight: .medium))
                    .foregroundStyle(
                        .white.opacity(0.30))
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
                    Color.endoCyan.opacity(0.30),
                    lineWidth: 0.5))
    }
}

#Preview {
    MissionBanner(
        title: "Air quality mission",
        missionBody: "AQI 148 detected nearby. Walk to Palmer Park for clean air.",
        onDismiss: {})
        .padding()
        .background(Color.bgPrimary)
}
