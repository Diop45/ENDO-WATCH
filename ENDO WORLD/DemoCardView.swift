import SwiftUI

struct DemoCardView: View {
    let step: Int
    let total: Int
    let headline: String
    let bodyCopy: String
    var onContinue: () -> Void

    var body: some View {
        ZStack {
            GeometryReader { geo in
                VStack(spacing: 0) {
                    Color.obSkyTop
                        .frame(height: geo.size.height * 0.45)
                    Color.obBg
                        .frame(height: geo.size.height * 0.55)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                DemoProductCard(step: step)
                    .padding(.top, 52)
                    .padding(.horizontal, 28)

                Spacer()

                VStack(spacing: 16) {
                    Text(headline)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.obNavy)
                        .multilineTextAlignment(.center)

                    Text(bodyCopy)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.obSlate)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)

                    HStack(spacing: 6) {
                        ForEach(0 ..< total, id: \.self) { i in
                            Circle()
                                .fill(i == step ? Color.obCyan : Color.obMuted)
                                .frame(width: 7, height: 7)
                                .animation(.easeInOut(duration: 0.2), value: step)
                        }
                    }

                    Button("Continue", action: onContinue)
                        .primaryCTA(bg: Color.obNavy, fg: .white)
                        .contentShape(Capsule())
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)
                .padding(.bottom, 54)
            }
        }
    }
}

private struct DemoProductCard: View {
    let step: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if step == 0 {
                Text("Zone score · Detroit, MI")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.black.opacity(0.38))
                    .kerning(1.0)
                    .textCase(.uppercase)
                    .padding(.bottom, 4)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("82")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(Color.obNavy)
                    Text("SUPPORTIVE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.obCyan)
                }
                .padding(.bottom, 6)

                ENDOSparkline(
                    values: [0.6, 0.55, 0.45, 0.38, 0.3, 0.22, 0.18, 0.08],
                    color: Color.obCyan
                )
                .frame(height: 36)
                .padding(.bottom, 6)

                HStack(spacing: 12) {
                    Text("AQI 38")
                        .font(.system(size: 9))
                        .foregroundStyle(.black.opacity(0.35))
                    Text("PM2.5 12.4")
                        .font(.system(size: 9))
                        .foregroundStyle(.black.opacity(0.35))
                }
            } else {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.endoRed.opacity(0.12))
                            .frame(width: 38, height: 38)
                        Image(systemName: "wind")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.endoRed)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text("AQI Hotspot · Score 28")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.obNavy)
                        Text("Hostile · 0.4mi away")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.obSlate)
                    }
                }
                .padding(.bottom, 8)

                Text("Route around →")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.obCyan)
            }
        }
        .padding(13)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.black.opacity(0.06), lineWidth: 0.5)
        )
    }
}
