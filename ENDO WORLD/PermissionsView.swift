import SwiftUI

struct PermissionsView: View {
    var onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.obBg.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    Text("ENDO needs a few things.")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.obNavy)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)

                    VStack(spacing: 10) {
                        PermRow(
                            icon: "location.fill",
                            title: "Location",
                            desc: "To score your current block",
                            color: Color.obCyan
                        )
                        PermRow(
                            icon: "heart.fill",
                            title: "Health",
                            desc: "To read Apple Watch biometrics",
                            color: Color(hex: "#FF6B6B")
                        )
                        PermRow(
                            icon: "bell.fill",
                            title: "Notifications",
                            desc: "For proximity health alerts",
                            color: Color(hex: "#FFB800")
                        )
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                Button("Allow access", action: onContinue)
                    .primaryCTA(bg: Color.obNavy, fg: .white)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 52)
                    .contentShape(Rectangle())
            }
        }
    }
}

private struct PermRow: View {
    let icon: String
    let title: String
    let desc: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.12))
                    .frame(width: 42, height: 42)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.obNavy)
                Text(desc)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.obSlate)
            }
            Spacer()
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(.black.opacity(0.06), lineWidth: 0.5)
        )
    }
}
