import SwiftUI

extension View {
    func primaryCTA(
        bg: Color = .endoCyan,
        fg: Color = .cyanCTA
    ) -> some View {
        self
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(fg)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(bg)
            .clipShape(Capsule())
    }

    func secondaryCTA() -> some View {
        self
            .font(.system(size: 14))
            .foregroundStyle(.white.opacity(0.55))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
            )
    }

    func endoCard(
        bg: Color = .bgSurface,
        border: Color = .white.opacity(0.08),
        radius: CGFloat = 14
    ) -> some View {
        self
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(border, lineWidth: 0.5)
            )
    }

    func capsLabel() -> some View {
        self
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(.white.opacity(0.35))
            .kerning(1.2)
            .textCase(.uppercase)
    }
}
