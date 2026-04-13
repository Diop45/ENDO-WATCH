import SwiftUI

struct SharedScanBanner: View {
    let session: SharedScanSession
    var onComplete: () -> Void

    var body: some View {
        TimelineView(
            .periodic(from: .now, by: 1)
        ) { _ in
            bannerContent
        }
    }

    private var bannerContent: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        Color.endoCyan.opacity(0.10))
                    .frame(width: 34, height: 34)
                Image(systemName:
                    "antenna.radiowaves.left.and.right")
                    .font(.system(
                        size: 14, weight: .semibold))
                    .foregroundStyle(Color.endoCyan)
            }

            VStack(alignment: .leading,
                   spacing: 2) {
                HStack(spacing: 6) {
                    Text("Shared scan active")
                        .font(.system(
                            size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(
                        "\(session.defenderCount) defenders")
                        .font(.system(
                            size: 9, weight: .medium))
                        .foregroundStyle(
                            Color.endoCyan)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Color.endoCyan.opacity(0.12))
                        .clipShape(Capsule())
                }
                Text(
                    session.sessionDuration + " remaining")
                    .font(.system(size: 10))
                    .foregroundStyle(
                        .white.opacity(0.40))
            }

            Spacer()

            Button("Complete") {
                onComplete()
            }
            .font(.system(
                size: 10, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Color.bgSurface)
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(
                    .white.opacity(0.15),
                    lineWidth: 0.5))
            .buttonStyle(.plain)
            .contentShape(Capsule())
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
    @Previewable @State var session = SharedScanSession(
        id: "preview",
        partnerUserId: "partner",
        coordinate: .init(latitude: 42.3314, longitude: -83.0458))
    SharedScanBanner(session: session, onComplete: {})
        .padding()
        .background(Color.bgPrimary)
}
